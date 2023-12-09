CREATE PROCEDURE dbo.MoveSkladTotal @Day0 datetime, @Day1 datetime,
  @VendList varchar(max), @StockList varchar(max), @HitagList varchar(max) -- поставщики,склады и товары.
--Например:
-- 1658,521,551,1759,833 
-- 552,555,79,54,202
-- 27749,30728,26774,10164,27492
AS
declare @DN0 int, @DN1 int, @today datetime, @tek datetime, @Comp varchar(30),
  @ParamDef nvarchar(50), @D0 datetime, @D1 datetime, @Cmd nvarchar(max),
  @StrDay0 varchar(20), @StrDay1 varchar(20)
  
BEGIN
  set @DN0=dbo.fnDatnom(@day0,1)
  set @DN1=dbo.fnDatnom(@day1,9999)
  set @StrDay0=''''+CONVERT(nvarchar(10), @day0, 104)+''''
  set @StrDay1=''''+CONVERT(nvarchar(10), @day1, 104)+''''
  set @today=convert(char(10), getdate(),104)
  set @Comp=HOST_NAME();

  -- Заготовка результата:
  create table #R(ND datetime, 
    Rest0Qty int,Rest0kg decimal(10,2), Rest0SC decimal(18,2), Rest0SP decimal(18,2),     -- утренние остат.
    InpQty int,InpSC decimal(10,2),InpSP decimal(10,2), InpKG decimal(10,2),              -- приход
    SellQty int,SellSC decimal(10,2),SellSP decimal(10,2), SellKG decimal(10,2),          -- продажи
    IzmcSC decimal(10,2),IzmcSP decimal(10,2),                                            -- переоценки
    CorrQty int,CorrSC decimal(10,2),CorrSP decimal(10,2), CorrKG decimal(10,2),          -- коррекции количества
    CorwSC decimal(10,2),CorwSP decimal(10,2), CorwKG decimal(10,2),                      -- коррекции веса
    RemvQty int,RemvSC decimal(10,2),RemvSP decimal(10,2), RemvKG decimal(10,2),          -- возврат поставщику
    MovMinusQty int,MovMinusSC decimal(10,2),MovMinusSP decimal(10,2), MovMinusKG decimal(10,2),  -- перемещения между складами в минус
    MovPlusQty int,MovPlusSC decimal(10,2),MovPlusSP decimal(10,2), MovPlusKG decimal(10,2),      -- перемещения между складами в плюс
    DivSC decimal(10,2),DivSP decimal(10,2), DivKG decimal(10,2),                         -- разбиения и слияния остатка
    TranSC decimal(10,2),TranSP decimal(10,2), TranKG decimal(10,2),                      -- трансмутация
    Rest1Qty int,Rest1kg decimal(10,2), Rest1SC decimal(18,2), Rest1SP decimal(18,2),     -- вечерние остатки
    );

  set @tek=@day0
  while @tek<=@day1 begin
    insert into #R(ND) values(@tek);
    set @tek=@tek+1;
  end;

  /**********************************************************
  **          Начальные остатки на складах:                **
  **********************************************************/
  set @cmd='update #R set Rest0Qty=E.Rest0Qty, Rest0sc=e.Rest0Sc,rest0sp=e.Rest0sp, rest0kg=E.Rest0kg '
    +'from #R '
    +'inner join ( '
      +'select v.Workdate,sum(v.MornRest) as Rest0Qty, sum(v.MornRest*v.Cost) as Rest0Sc,'
       +'sum(v.MornRest*v.Price) as Rest0sp,'
       +'sum(v.MornRest*v.Weight)as Rest0kg '
      +'from MorozArc..ArcVI V '
      +'where '
        +'V.workdate between @d0 and @d1 ';
  if @StockList<>'' set @Cmd=@Cmd+' and Sklad in ('+@StockList+') '
  if @VendList<>'' set @Cmd=@Cmd+' and Ncod in ('+@VendList+') '
  if @HitagList<>'' set @Cmd=@Cmd+' and Hitag in ('+@HitagList+') '
  set @Cmd=@Cmd+' group by v.WorkDate) E on E.WorkDate=#R.ND';
  SET @ParamDef = N'@D0 datetime, @D1 datetime';
  execute sp_executesql @cmd, @ParamDef, @day0, @day1;

  /**********************************************************
  **    Отдельный расчет начальных остатков на сегодня     **
  **********************************************************/
  if exists(select * from #R where nd=dbo.today()) begin
    set @CMD='update #R set Rest0Qty=E.Qty,Rest0SC=E.SC,Rest0sp=E.SP, Rest0kg=E.kg '
      +'from ( select sum(v.EveningRest) Qty, sum(v.EveningRest*v.Cost) SC,'
      +'sum(v.EveningRest*v.Price) SP, sum(v.EveningRest*v.Weight) KG '
      +'from MorozArc..ArcVI V where v.workdate=dbo.today()-1'
    if @StockList<>'' set @Cmd=@Cmd+' and Sklad in ('+@StockList+') '
    if @VendList<>''  set @Cmd=@Cmd+' and Ncod in ('+@VendList+') '
    if @HitagList<>'' set @Cmd=@Cmd+' and Hitag in ('+@HitagList+') ';
    set @cmd=@cmd+') E where #r.nd=dbo.today()';
    execute (@CMD);
  end;

  /**********************************************************
  **  И отдельный расчет конечных остатков на сегодня      **
  **********************************************************/
  if exists(select * from #R where nd=dbo.today()) begin
    set @CMD='update #R set Rest1Qty=E.Qty,Rest1SC=E.SC,Rest1sp=E.SP, Rest1kg=E.kg '
      +'from ( select sum(v.morn-v.sell+v.isprav-v.remov) Qty, sum((v.morn-v.sell+v.isprav-v.remov)*v.Cost) SC,'
      +'sum((v.morn-v.sell+v.isprav-v.remov)*v.Price) SP, '
      +'sum((v.morn-v.sell+v.isprav-v.remov)*iif(nm.flgWeight=0,0,v.weight)) KG '
      +'from tdvi V inner join Nomen nm on nm.hitag=v.hitag where 0=0'
    if @StockList<>'' set @Cmd=@Cmd+' and v.Sklad in ('+@StockList+') '
    if @VendList<>''  set @Cmd=@Cmd+' and v.Ncod in ('+@VendList+') '
    if @HitagList<>'' set @Cmd=@Cmd+' and v.Hitag in ('+@HitagList+') ';
    set @cmd=@cmd+') E where #r.nd=dbo.today()';
    execute (@CMD);
  end;





  /**********************************************************
  **          Поставки товаров за период                   **
  **********************************************************/
  set @cmd='update #R set InpQty=E.Qty, Inpsc=e.Sc,Inpsp=e.sp, Inpkg=E.kg '
  +'from #R inner join ( '
  +'  select cm.date as ND, sum(i.kol) as Qty,'
  +'  sum(i.kol*i.cost) as SC,'
  +'  sum(i.kol*i.Price) as SP,'
  +'  sum(i.kol*iif(nm.flgweight=0,0,i.weight)) as KG '
  +'  from comman cm inner join inpdet i on cm.ncom=i.ncom inner join nomen nm on nm.hitag=i.hitag '
  +'  where cm.date between '+@StrDay0+' and '+@StrDay1+' ';
  if @StockList<>'' set @Cmd=@Cmd+' and i.Sklad in ('+@StockList+') '  
  if @VendList<>'' set @Cmd=@Cmd+' and cm.Ncod in ('+@VendList+') '  
  if @HitagList<>'' set @Cmd=@Cmd+' and i.Hitag in ('+@HitagList+') '  
  set @cmd=@cmd+'  group by cm.date) E on E.nd=#r.nd';
  execute (@CMD);

  /**********************************************************
  **          Продажи товаров за период                    **
  **********************************************************/
  set @Cmd='update #R set SellQty=E.Qty, SellSC=E.SC,SellSP=E.SP, SellKG=E.KG '
  +'from #R inner join(select nc.nd, sum(nv.kol) as Qty,'
  +'  sum(nv.kol*nv.cost) as SC, sum(nv.kol*nv.price*(1.0+0.01*NC.Extra)) as SP,'
  +'  sum(case'
  +'    when nm.flgWeight=0 then 0'
  +'    when nc.nd<dbo.today() then iif(vi.weight=0,nv.kol*nm.netto,nv.kol*vi.weight)'
  +'    else iif(tv.weight=0,nv.kol*nm.netto,nv.kol*tv.weight) end) as KG'
  +'  from NC inner join Nv on nv.datnom=nc.datnom'
  +'  inner join Nomen nm on nm.hitag=nv.Hitag left join Visual vi on vi.ID=nv.tekid'
  +'  left join tdvi tv  on tv.ID=nv.tekid '
  +'  where nc.nd between '+@StrDay0+' and '+@StrDay1+' ';
      if @StockList<>'' set @Cmd=@Cmd+' and nv.Sklad in ('+@StockList+') '  
      if @HitagList<>'' set @Cmd=@Cmd+' and vi.hitag in ('+@HitagList+') '  
      if @VendList<>'' set @Cmd=@Cmd+' and (vi.id is not null and vi.ncod in ('+@VendList+')  or tv.id is not null and tv.Ncod in ('+@VendList+'))';
  set @Cmd=@Cmd+' group by nc.nd) E on E.ND=#R.ND';
  execute (@CMD);


  /**********************************************************
  **          Переоценки остатков на складе за период      **
  **********************************************************/
  set @CMD='update #R set IzmcSC=E.SC,IzmcSP=E.SP from #R inner join'
  +'(select nd,sum(kol*(newcost-cost)) as SC,sum(kol*(newPrice-Price)) as SP '
  +'from izmen '
  +'  where nd between '+@StrDay0+' and '+@StrDay1+' and Act=''ИзмЦ'' ';
    if @StockList<>'' set @Cmd=@Cmd+' and Sklad in ('+@StockList+') '  
    if @HitagList<>'' set @Cmd=@Cmd+' and hitag in ('+@HitagList+') '  
    if @VendList<>'' set @Cmd=@Cmd+' and ncod in ('+@VendList+')';
  set @Cmd=@Cmd+' group by nd) E on E.ND=#R.ND';
  execute (@CMD);


  /**********************************************************
  **     Коррекции остатков за период, операция 'Испр'     **
  **********************************************************/
  set @cmd='update #R set CorrQty=E.Qty,CorrSC=E.SC,corrSP=E.SP,CorrKG=E.KG '
  +'from #R inner join (select nd, sum(NewKol-Kol) Qty, sum((newKol-Kol)*Cost) SC, '
  +'  sum((newkol-Kol)*Price) SP, sum((NewKol-Kol)*weight) KG '
  +'  from izmen '
  +'  where nd between '+@StrDay0+' and '+@StrDay1+' and Act=''Испр'' ';
      if @StockList<>'' set @Cmd=@Cmd+' and Sklad in ('+@StockList+') '  
      if @HitagList<>'' set @Cmd=@Cmd+' and hitag in ('+@HitagList+') '  
      if @VendList<>'' set @Cmd=@Cmd+' and ncod in ('+@VendList+')';
  set @cmd=@cmd+'  group by ND) E on E.ND=#R.ND'
  execute(@cmd)

  /**********************************************************
  **     Возврат товаров поставщику, операция 'Снят'       **
  **********************************************************/
  set @cmd='update #R set RemvQty=E.Qty,RemvSC=E.SC,RemvSP=E.SP,RemvKG=E.KG '
  +'from #R inner join (select nd, sum(Kol-NewKol) Qty, sum((Kol-NewKol)*Cost) SC, '
  +'  sum((kol-NewKol)*Price) SP, sum((Kol-NewKol)*weight) KG '
  +'  from izmen '
  +'  where nd between '+@StrDay0+' and '+@StrDay1+' and Act=''Снят'' ';
      if @StockList<>'' set @Cmd=@Cmd+' and Sklad in ('+@StockList+') '  
      if @HitagList<>'' set @Cmd=@Cmd+' and hitag in ('+@HitagList+') '  
      if @VendList<>'' set @Cmd=@Cmd+' and ncod in ('+@VendList+')';
  set @cmd=@cmd+'  group by ND) E on E.ND=#R.ND'
  execute(@cmd)


  /***********************************************************
  **     Перемещение между складами, операция 'Скла'в минус **
  ***********************************************************/
  set @CMD='update #R set MovMinusQty=E.Qty,MovMinusSC=E.SC, MovMinusSP=E.SP, MovMinusKG=E.KG '
    +'from #R inner join (select nd, sum(kol) as Qty, sum(kol*cost) as SC, sum(kol*price) as SP, '
    +'sum(kol*weight) as KG from izmen '
    +'where nd between '+@StrDay0+' and '+@StrDay1+' and Act=''Скла'' ';
      if @StockList<>'' set @Cmd=@Cmd+' and Sklad in ('+@StockList+') '  
      if @HitagList<>'' set @Cmd=@Cmd+' and hitag in ('+@HitagList+') '  
      if @VendList<>'' set @Cmd=@Cmd+' and ncod in ('+@VendList+')';
  set @cmd=@cmd+'  group by ND) E on E.ND=#R.ND'
  execute(@cmd)

  /***********************************************************
  **     Перемещение между складами, операция 'Скла' в плюс **
  ***********************************************************/
  set @CMD='update #R set MovPlusQty=E.Qty,MovPlusSC=E.SC, MovPlusSP=E.SP, MovPlusKG=E.KG '
    +'from #R inner join (select nd, sum(kol) as Qty, sum(kol*cost) as SC, sum(kol*price) as SP, '
    +'sum(kol*weight) as KG from izmen '
    +'where nd between '+@StrDay0+' and '+@StrDay1+' and Act=''Скла'' ';
      if @StockList<>'' set @Cmd=@Cmd+' and NewSklad in ('+@StockList+') '  
      if @HitagList<>'' set @Cmd=@Cmd+' and hitag in ('+@HitagList+') '  
      if @VendList<>'' set @Cmd=@Cmd+' and ncod in ('+@VendList+')';
  set @cmd=@cmd+'  group by ND) E on E.ND=#R.ND'
  execute(@cmd)

  /***********************************************************
  **     Операция DIV                                      **
  ***********************************************************/
  set @CMD='update #R set DivSC=E.SC,DivSP=E.SP,DivKG=E.KG '
  +'from #R inner join (select ND, '
  +'sum((kol-Newkol)*Cost) SC,sum((kol-Newkol)*Price) SP, sum((newkol-kol)*iif(weight=0,newweight,weight)) KG '
  +'from Izmen '
  +'where nd between '+@StrDay0+' and '+@StrDay1+' and Act like ''Div%'' ';
    if @StockList<>'' set @Cmd=@Cmd+' and NewSklad in ('+@StockList+') '  
    if @HitagList<>'' set @Cmd=@Cmd+' and hitag in ('+@HitagList+') '  
    if @VendList<>'' set @Cmd=@Cmd+' and ncod in ('+@VendList+')';
  set @cmd=@cmd+'  group by ND) E on E.ND=#R.ND';
  execute(@cmd);


  set @CMD='update #R set TranSC=E.SC, TranSP=E.SP, TranKG=E.KG '
  +'from #r inner join (select nd,'
  +' sum(newkol*newprice-kol*price) as SP,'
  +' sum(newkol*newprice-kol*price) as SC,'
  +' sum(newkol*newweight-kol*weight) as KG '
  +'from Izmen where nd between '+@StrDay0+' and '+@StrDay1+' and Act=''Tran'' ';
    if @StockList<>'' set @Cmd=@Cmd+' and Sklad in ('+@StockList+') '  ;
    if @HitagList<>'' set @Cmd=@Cmd+' and (hitag in ('+@HitagList+') or Newhitag in ('+@HitagList+')) ';
    if @VendList<>''  set @Cmd=@Cmd+' and ncod in ('+@VendList+')';
  set @cmd=@cmd+'  group by ND) E on E.ND=#R.ND';
  execute(@cmd);


  set @CMD='update #R set TranKG=E.KG,TranSC=E.SC,TranSP=E.SP '
  +'from #R inner join (select nd, sum((newkol-kol)*newweight) as KG,'
  +'sum((newKol-Kol)*NewCost) as SC,sum((newKol-Kol)*NewPrice) as SP '
  +'from Izmen where nd between '+@StrDay0+' and '+@StrDay1+' and Act=''испв'' ';
    if @StockList<>'' set @Cmd=@Cmd+' and Sklad in ('+@StockList+') '  ;
    if @HitagList<>'' set @Cmd=@Cmd+' and hitag in ('+@HitagList+') ';
    if @VendList<>''  set @Cmd=@Cmd+' and ncod in ('+@VendList+')';
  set @cmd=@cmd+'  group by ND) E on E.ND=#R.ND';
  execute(@cmd);


 -- Считаем, что утренние остатки равны остатка на вечер предыдущего дня:
 update #R set Rest1Qty=r1.rest0qty, Rest1sc=r1.Rest0sc, rest1sp=r1.Rest0sp, rest1kg=r1.Rest0kg
 from #R inner join #R R1 on #r.nd+1=r1.nd

select * from #r order by nd;
end;