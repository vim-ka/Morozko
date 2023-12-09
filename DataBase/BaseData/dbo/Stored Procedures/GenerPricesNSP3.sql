CREATE procedure GenerPricesNSP3 @DCK int, @Comp varchar(20), @Datnom int=null, @RewritePrices bit=0
as
declare @B_ID int, @theNMID int, @theMaster int, @DFID int 
declare @theOblID int, @theRNID int, @theDepID int
declare @theSvID int, @theAgID int, @theB_ID int
begin
  set @B_ID=(select Pin from Defcontract where DCK=@DCK and ContrTip=2);
  
  --ГОТОВЛЮ ЛОКАЛЬНУЮ КОПИЮ СКЛАДА
  create table #t (ngrp int, id int, hitag int, OnlyMinp bit, Sklad int, 
    Ncod int, [Parent] int, MainParent int, weight decimal(10,3), netto decimal(10,3),
    MinP int, Mpu int, OrigPrice decimal(12,2), NewPrice decimal(10,2), 
    Cost decimal(14,5), Ostat int, Locked bit, SkladLock bit,
    MinExtra decimal(6,2),
    LastMonthUsed tinyint, DisMinExtra bit,
    Nacen decimal(6,2), nmid int, Disab bit default 0, NDS int, VesFlag bit default 0);


  if @Datnom is null or @Datnom=0
    insert into #t (ngrp, id, hitag, Onlyminp, Sklad, ncod, [Parent], MainParent, WEIGHT, netto,
      MinP, Mpu, Origprice, Cost, 
      [Ostat], 
      Locked, SkladLock, MinExtra, 
      LastMonthUsed, DisMinExtra, NDS)
    select 
      nm.ngrp, v.id, v.hitag, s.OnlyMinp, v.sklad,  v.ncod, gr.Parent, gr.MainParent, v.weight, nm.netto, 
      V.MinP, V.Mpu, v.price as OrigPrice, V.Cost, 
      v.morn-v.sell+v.isprav-v.remov-v.bad as [Ostat],
      V.LOCKED, S.Locked as SkladLock, nm.MinExtra, 
      SIGN(isnull(L.Hitag,0)) as LastMonthUsed, S.DisMinExtra, nm.nds
    from 
      TDVI V inner join GenerNsp2sklad G on G.Comp=@Comp and G.sklad=V.Sklad and G.Enab=1
      inner join Nomen nm on nm.hitag=v.HITAG
      inner join GR on GR.Ngrp=nm.ngrp
      inner join Skladlist S on S.SkladNo=v.sklad
      left join BigMonthList L on L.Hitag=v.Hitag and L.B_ID=@b_id
    where v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV > 0;
  else if dbo.DatnomInDate(@datnom)=cast(floor(cast(getdate() as decimal(38,19))) as datetime)
    insert into #t (ngrp, id, hitag, Onlyminp, Sklad, ncod, [Parent], MainParent, WEIGHT, netto, 
      MinP, Mpu, Origprice, Cost, 
      [Ostat], 
      Locked, SkladLock, MinExtra, 
      LastMonthUsed, DisMinExtra, NDS)
    select 
      nm.ngrp, v.id, v.hitag, s.OnlyMinp, v.sklad,  v.ncod, gr.Parent, gr.MainParent, v.weight, nm.netto, 
      V.MinP, V.Mpu, v.price as OrigPrice, V.Cost, 
      v.morn-v.sell+v.isprav-v.remov-v.bad as [Ostat],
      V.LOCKED, S.Locked as SkladLock, nm.MinExtra, 
      SIGN(isnull(L.Hitag,0)) as LastMonthUsed, S.DisMinExtra, nm.nds
    from 
      TDVI V inner join NV on NV.Datnom=@Datnom and NV.TekID=V.id
      inner join GenerNsp2sklad G on G.Comp=@Comp and G.sklad=V.Sklad and G.Enab=1
      inner join Nomen nm on nm.hitag=v.HITAG
      inner join GR on GR.Ngrp=nm.ngrp
      inner join Skladlist S on S.SkladNo=v.sklad
      left join BigMonthList L on L.Hitag=v.Hitag and L.B_ID=@b_id
    where v.MORN-v.SELL+v.ISPRAV-v.REMOV-v.REZERV > 0;
  else
    insert into #t (ngrp, id, hitag, Onlyminp, Sklad, ncod, [Parent], MainParent, WEIGHT, netto,
      MinP, Mpu, Origprice, Cost, 
      [Ostat], 
      Locked, SkladLock, MinExtra, 
      LastMonthUsed, DisMinExtra, NDS)
    select 
      nm.ngrp, v.id, v.hitag, s.OnlyMinp, v.sklad,  v.ncod, gr.Parent, gr.MainParent, v.weight, nm.netto, 
      V.MinP, V.Mpu, v.price as OrigPrice, V.Cost, 
      v.morn-v.sell+v.isprav-v.remov-v.bad as [Ostat],
      V.LOCKED, S.Locked as SkladLock, nm.MinExtra, 
      SIGN(isnull(L.Hitag,0)) as LastMonthUsed, S.DisMinExtra, nm.nds
    from 
      VISUAL V inner join NV on NV.Datnom=@Datnom and NV.TekID=V.id
      inner join GenerNsp2sklad G on G.Comp=@Comp and G.sklad=V.Sklad and G.Enab=1
      inner join Nomen nm on nm.hitag=v.HITAG
      inner join GR on GR.Ngrp=nm.ngrp
      inner join Skladlist S on S.SkladNo=v.sklad
      left join BigMonthList L on L.Hitag=v.Hitag and L.B_ID=@b_id;
  
    
  
  create index t_temp_idx on #t(id);

  -- Кто наш покупатель, какого роду-племени?

  select 
    @theAgID=DC.ag_id, @theB_ID=DC.Pin, @theDepID=SV.DepID,
    @theRnID=D.Rn_ID,
    @theOblID=D.Obl_ID,
    @theMaster=D.[Master],
    @DFID=D.dfID
  from 
    DefContract DC 
    inner join Agentlist A on A.AG_ID=DC.ag_id
    inner join AgentList SV on SV.AG_ID=A.sv_ag_id
    inner join Def D on D.pin=dc.pin
  where 
    dc.DCK=@DCK and Dc.ContrTip=2

  -- ИЗ СПИСКА ЗАДАЧ ПО НАЦЕНКЕ ОТБИРАЮ ОТНОСЯЩИЕСЯ К ЗАДАННОМУ ПОКУПАТЕЛЮ:
  declare CurMain cursor fast_forward  
  for 
    select distinct w.nmid
    from 
      NetSpec2_Who w 
      inner join netspec2_main m on m.nmid=w.nmid
    where
      ( (w.CodeTip=1 and w.Code=@theOblID)
        or (w.CodeTip=2 and w.Code=@theRnID)
        or (w.CodeTip=3 and w.Code=@theDepID)
        or (w.CodeTip=4 and w.Code=@theSvID)
        or (w.CodeTip=5 and w.Code=@theAgID)
        or (w.CodeTip=6 and w.Code=@theMaster and @theMaster>0)
        or (w.CodeTip=7 and w.Code=@theB_ID)
      )
      and m.Activ=1 and GetDate() between m.StartDate and m.FinishDate;
 
  open CurMain; 
  fetch next from CurMain into @theNMID;
  WHILE (@@FETCH_STATUS=0)  BEGIN
    -- Теперь у нас есть номер задачи по наценке, которая точно относится к покупателю.

    -- Перво-наперво запрет продаж. Запрет для товаров с известным кодом:
    update #t 
    set #t.Disab=1 where nmid is null 
      and #t.hitag in (select Code from netspec2_what T 
      where t.nmid=@theNMID and T.RezTip=2 and T.CodeTip=2);
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and #t.disab=1;

    -- Запрет продаж товаров известной группы:
    update #t 
      set #t.Disab=1 
      where nmid is null 
      and ((#t.Ngrp in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=2 and T.CodeTip=1))
             or (#t.Parent in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=2 and T.CodeTip=1))
             or (#t.MainParent in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=2 and T.CodeTip=1))
          );
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and #t.disab=1;
          
    -- Запрет продаж товаров известного поставщика:
    update #t 
      set #t.Disab=1 
      where nmid is null 
      and #t.Ncod in (select Code from netspec2_what T where t.nmid=@theNMID and T.RezTip=2 and T.CodeTip=0);
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and #t.disab=1;      

    -- Далее подправим цены по штучным товарам с известным кодом:
    update #t 
    set NewPrice=(select Rez from netspec2_what T 
      where t.nmid=@theNMID and T.RezTip=1 and T.Code=#t.hitag and T.CodeTip=2 and T.isWeightPrice=0)
    where nmid is null;
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and NewPrice is not null;
    
    
    
    

    -- Далее подправим цены по весовым товарам с известным кодом:
    update #t 
    set VesFlag=1, NewPrice=[WEIGHT]*(select Rez from netspec2_what T 
      where t.nmid=@theNMID and T.RezTip=1 and T.Code=#t.hitag and T.CodeTip=2 and T.isWeightPrice=1)
    where nmid is null  and [WEIGHT]>0;
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and NewPrice is not null;


    -- возможно, вес товара не обозначен явно как Weight>0, тогда
    -- нужно взять его из nomen.netto.
    -- ВОТ ЭТОТ КУСОК НЕ РАБОТАЕТ КАК ДОЛЖЕН!
    --update #t 
    --set VesFlag=1, NewPrice=(select Rez from netspec2_what T 
    --  where T.nmid=@theNMID and T.RezTip=1 and T.Code=#t.hitag and T.CodeTip=2 and T.isWeightPrice=1)
    --where #t.nmid is null and (#t.[WEIGHT] is null or  #t.[WEIGHT]=0)
    --  А вот этот вроде должен:
    update #t 
    set VesFlag=1, NewPrice=Netto*(select Rez from netspec2_what T 
      where t.nmid=@theNMID and T.RezTip=1 and T.Code=#t.hitag and T.CodeTip=2 and T.isWeightPrice=1)
    where nmid is null and isnull(WEIGHT,0)=0 and Netto>0;
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID where NmID is null and NewPrice is not null;




    -- А если задана наценка, то неважно, весовой товар или штучный:
    update #t 
    set Nacen=(select Rez from netspec2_what T 
      where T.nmid=@theNMID and T.RezTip=0 and T.Code=#t.hitag and T.CodeTip=2 )
    where nmid is null;
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID, NewPrice=OrigPrice*(1.0+Nacen/100.0) where NmID is null and Nacen is not null;

    -- Теперь устанавливаю НАЦЕНКУ для товаров с известной группой:
    update #t 
    set Nacen=(select max(Rez) from netspec2_what T 
      where t.nmid=@theNMID and T.RezTip=0 and (T.Code=#t.ngrp or T.Code=#t.MainParent or T.Code=#t.Parent) 
      and T.CodeTip=1)
      where nmid is null;
    -- Исключаю обработанные строки из дальнейшего рассмотрения:
    update #t set NmID=@TheNMID, NewPrice=OrigPrice*(1.0+Nacen/100.0) where NmID is null and Nacen is not null;

    -- Следующая строка в курсоре:
    fetch next from CurMain into @theNMID;
  end;
  close  CurMain;
  deallocate CurMain;


  if  (@Datnom is not NULL) and (@RewritePrices=1) begin
    update NV set Price=(select #t.NewPrice from #t where #t.id=nv.TekID)
    where nv.DatNom=@datnom and nv.tekid in (select id from #t where NewPrice>0);
    
    update NC set 
      SP=(1.0+nc.extra/100)*(select sum(nv.kol*nv.price) from nv where datnom=@Datnom),
      SC=(select sum(nv.kol*nv.cost) from nv where datnom=@Datnom)
    where nc.datnom=@datnom;
    
  end;
  
  select #t.*, nm.[name], N.MinNacen
  from 
    #t 
    inner join Nomen NM on nm.hitag=#t.Hitag --where Nmid is not null
    left join DefFormatNacen N on N.dfID=@dfid and N.Ngrp=#t.MainParent
END