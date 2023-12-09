CREATE procedure CalcRetroBonusPay2
  @comp varchar(30), @RBID int, @Rbv2 int, @RRG int=0
  with recompile
as
declare @day0 datetime, @day1 datetime
declare @NcodList varchar(100)
declare @BonusPerc decimal(12,2)
declare @PayBySell bit
declare @n0 int, @n1 int, @n10 int, @n20 int
declare @TekNcod int
declare @TekNgrp int
declare @TekHitag int
declare @Period0 datetime
declare @Period1 datetime
declare @TotalSP decimal(12,2)
declare @Active bit
declare @datnom int,@tekid int,@ncod int,@ngrp int,@hitag int,@Pin int,@NetMode bit,@Sell int,@Sp decimal(12,2),@Prod decimal(12,2)
declare @Koeff decimal(6,2)
declare @Treshold12 bit, @flgWoNds bit
declare @OurID tinyint

begin
  set @Treshold12=(select Treshold12 from rb_main where rbid=@rbid);
  if isnull(@Treshold12,0)=0 set @Koeff=-1; else set @Koeff=1.12;

  if (@RRG>0) delete From rb_result where RRG=@RRG;
  if (@RRG=0) delete From rb_result where Comp=@Comp and RRG=0;
  
  select @Day0=v.day0, @Day1=v.day1, @NcodList=v2.NcodList
  from rb_Vedom2 v2 inner join rb_vedom v on v.rbv=v2.rbv 
  where v2.rbv2=@rbv2;
  

  -- Период действия ретробонуса:
  select @period0=m.StartDay, @Period1=m.FinishDay, @PayBySell=m.PayBySell, 
    @Active=m.Active, @flgWoNds=m.flgWoNds
  From rb_main m where m.rbid=@RBID;


  -- список допустимых поставщиков:
  create table #Ve(ncod int);
  insert into #Ve select * from dbo.Str2intarray(@NcodList);
  create index tmp_ve_idx on #ve(ncod);
  
  -- if @LastStart is null set @LastStart=@Day0;
  
  -- Промежуточная таблица продаж:
  create table #t (datnom int, tekid int, Ncod int, Ngrp int,
    hitag int, 
    pin int,  NetMode Bit, Sell int, Prod decimal(12,2), SP decimal(12,2), OurID tinyint);


  -- исходные данные содержатся в таблицах rb_main, rb_buyers, rb_filter
  if (@Period0<=@day1) and (@Period1>=@Day0) and (@Active=1) BEGIN
    set @n0=dbo.InDatNom(1, @day0)  -- период расчета
    set @n1=dbo.InDatNom(9999, @day1)
    set @n10=dbo.InDatNom(1, @period0) 
    set @n20=dbo.InDatNom(9999, @period1)
    
    -- Список накладных, в которых вообще присутствовали товары указанных поставщиков:
    /*
    create table #p(datnom int);
    insert into #p 
      select distinct nv.datnom 
      from nv inner join Visual v on v.id=nv.tekid 
      inner join #ve on #ve.ncod=v.ncod;
    create index ptabl_tempx_idx on #p(datnom);
    */
    
    -- Список накладных, по которым были какие-то выплаты за указанный период
    -- и присутствовали товары указанных поставщиков:
    create table #pay (NcDatnom int, Part decimal(15,9))
    -- В списке указана накладная и коэффициент оплаты, напр. 0.5 для половинной оплаты накладной
    insert into #pay(NcDatnom, Part)
    select NcDatnom, Part from (
      select 
        k.sourdatnom as NcDatnom, nc.SP, sum(k.plata) as KassaPlata, 
        sum(k.plata)/(0.00+case when isnull(Nc.SP,0)=0 then 1 else nc.sp end) as Part
      from 
        kassa1 k 
        inner join Nc on Nc.datnom=k.SourDatNom
        -- inner join #p on #p.datnom=Nc.datnom
      where 
        k.b_id>0 and k.oper=-2 and k.act='ВЫ'
        and nc.sc<>0 and nc.sp<>0
        and (
          (isnull(k.bank_id,0)=0 and k.nd between @day0 and @day1 and k.nd between @period0 and @period1)
          or (isnull(k.bank_id,0)<>0 and k.bankday between @day0 and @day1 and k.bankday between @period0 and @period1)
          )
        and k.plata<>0
        and nc.Actn=0 and k.Actn=0
      group by k.sourdatnom,nc.SP
      having sum(k.plata)<>0) E
    -- Индексирую для скорости
    create INDEX pay_nnak_idx on #pay(ncDatnom)
    
    

    -- Есть ли фильтры с полной номенклатурой? 
    -- К ним относятся фильтры "Все вообще" (Еще было и "Все кроме чего-то". Отменено).
    -- Если есть фильтры с полной номенклатурой - для начала выдираю всё из этого списка накладных:
    if exists(select * from rb_Filter where rbid=@rbid and tip=0)    
    insert into #t(datnom, tekid, ncod, ngrp, hitag,pin,netmode,sell,prod,sp,OurID)
    select 
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp, NV.hitag, 
      nc.B_ID as pin, b.NetMode, sum(nv.Kol) as Sell, 
      sum(nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as prod,
      sum(#pay.part*nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as SP,
      nc.OurID
    From 
      nv 
      inner join #pay on #pay.ncDatnom=nv.datnom
      inner join nc on nc.datnom=nv.datnom
      inner join Def D on D.pin=nc.B_ID and d.tip=1
      inner join rb_buyers b on b.Pin=D.Pin or (b.NetMode=1 and b.Pin=D.[Master])
      inner join rb_main m on m.RbID=b.rbid
      inner join Nomen nm on nm.hitag=nv.hitag
      inner join gr on gr.Ngrp=nm.ngrp
      inner join visual vi on vi.id=nv.TekID
      inner join #ve on #ve.ncod=vi.ncod
    where 
      b.RbId=@RBID
      --and nv.datnom between @n0 and @n1 -- период расчета
      --and nv.datnom between @n10 and @n20 -- период действия фильтра
      and nv.Kol<>0
      and m.[Active]=1
      and (nv.price*(1.0+nc.extra/100)>=@koeff*nv.Cost or gr.MainParent=3)
      and nc.Actn=0
    group by
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp, NV.hitag, nc.B_ID, b.NetMode, nc.OurID;


    -- Теперь дописываю продажи всего по указанным поставщикам,
    -- но избегаю дубликатов:
    declare cr cursor fast_forward for select 
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp,
      NV.hitag, 
      nc.B_ID as pin, b.NetMode, sum(nv.Kol) as Sell, 
      sum(nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as prod,
      sum(#pay.part*nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as SP,
      nc.OurID
    From 
      nv 
      inner join #pay on #pay.ncDatnom=nv.datnom
      inner join nc on nc.datnom=nv.datnom
      inner join Def D on D.pin=nc.B_ID and d.tip=1
      inner join rb_buyers b on b.Pin=D.Pin or (b.NetMode=1 and b.Pin=D.[Master])
      inner join rb_main m on m.RbID=b.rbid
      inner join Visual Vi on vi.id=nv.TekID    
      inner join rb_filter f on f.RbID=m.RbID and f.tip=4 and f.k=vi.ncod
      inner join Nomen nm on nm.hitag=nv.hitag
      inner join gr on gr.Ngrp=nm.ngrp
      inner join #ve on #ve.ncod=vi.ncod
    where 
      m.RbID=@RBID
      -- and nv.datnom between @n0 and @n1
      -- and nv.datnom between @n10 and @n20 --  and nc.nd between m.StartDay and m.FinishDay
      and nv.Kol<>0
      and m.[Active]=1
      and (nv.price*(1.0+nc.extra/100)>=@koeff*nv.Cost or gr.MainParent=3)
      and nc.Actn=0
    group by
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp, NV.hitag, nc.B_ID, b.NetMode, nc.OurID;
    open cr;
    fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Prod,@Sp,@OurID
    WHILE (@@FETCH_STATUS=0)  BEGIN
      if not EXISTS(select * From #t where datnom=@datnom and tekid=@tekid)
      insert into #t(datnom,tekid,ncod,ngrp,hitag,Pin,NetMode,Sell,Prod,Sp,OurID)
      VALUES(@datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Prod,@Sp,@OurID);
    fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Prod,@Sp,@OurID
    END;
    close cr;
    deallocate cr;    
    
    

    -- Теперь продажи всего по указанным группам товаров:
    declare cr cursor fast_forward for select 
      nv.DatNom, nv.tekid, vi.ncod, nm.ngrp,
      NV.hitag, 
      nc.B_ID as pin, b.NetMode, sum(nv.Kol) as Sell, 
      sum(nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as prod,
      sum(#pay.part*nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as SP,
      nc.OurID
    From 
      nv 
      inner join #pay on #pay.ncDatnom=nv.datnom
      inner join nc on nc.datnom=nv.datnom
      inner join Def D on D.pin=nc.B_ID and d.tip=1
      inner join rb_buyers b on b.Pin=D.Pin or (b.NetMode=1 and b.Pin=D.[Master])
      inner join rb_main m on m.RbID=b.rbid
      inner join Nomen NM on NM.Hitag=nv.Hitag
      inner join gr on gr.Ngrp=nm.ngrp
      inner join rb_filter f on f.RbID=m.RbID and f.tip=5 and nm.Ngrp=f.K
      inner join Visual Vi on vi.id=nv.TekID    
      inner join #ve on #ve.ncod=vi.ncod
    where 
      m.RbID=@RBID
      -- and nv.datnom between @n0 and @n1
      -- and nv.datnom between @n10 and @n20 -- and nc.nd between m.StartDay and m.FinishDay
      and nv.Kol<>0
      and m.[Active]=1
      and (nv.price*(1.0+nc.extra/100)>=@koeff*nv.Cost or gr.MainParent=3)
      and nc.Actn=0
    group by
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp, NV.hitag, nc.B_ID, b.NetMode, nc.OurID;
    open cr;
    fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Prod,@Sp,@OurID
    WHILE (@@FETCH_STATUS=0)  BEGIN
      if not EXISTS(select * From #t where datnom=@datnom and tekid=@tekid)
      insert into #t(datnom,tekid,ncod,ngrp,hitag,Pin,NetMode,Sell,Prod,Sp,OurID)
      VALUES(@datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Prod,@Sp,@OurID);
      fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Prod,@Sp,@OurID
    END;
    close cr;
    deallocate cr;

    
    -- Теперь продажи всего по указанным кодам товаров:
    declare cr cursor fast_forward for select 
      nv.DatNom, nv.tekid, vi.ncod, nm.ngrp,
      NV.hitag, 
      nc.B_ID as pin, b.NetMode, sum(nv.Kol) as Sell, 
      sum(nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as prod,
      sum(#pay.part*nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as SP,
      nc.OurID
    From 
      nv 
      inner join #pay on #pay.ncDatnom=nv.datnom
      inner join nc on nc.datnom=nv.datnom
      inner join Def D on D.pin=nc.B_ID and d.tip=1
      inner join rb_buyers b on b.Pin=D.Pin or (b.NetMode=1 and b.Pin=D.[Master])
      inner join rb_main m on m.RbID=b.rbid
      inner join Nomen NM on NM.Hitag=nv.Hitag
      inner join gr on gr.Ngrp=nm.ngrp
      inner join rb_filter f on f.RbID=m.RbID and f.tip=6 and nv.hitag=f.K
      inner join Visual Vi on vi.id=nv.TekID and (nv.price*(1.0+nc.extra/100)>=@koeff*nv.Cost or gr.MainParent=3)
      inner join #ve on #ve.ncod=vi.ncod
    where 
      m.RbID=@RBID
      -- and nv.datnom between @n0 and @n1
      -- and nv.datnom between @n10 and @n20 -- and nc.nd between m.StartDay and m.FinishDay
      and nv.Kol<>0
      and m.[Active]=1
      and nc.Actn=0
    group by
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp, NV.hitag, nc.B_ID, b.NetMode, nc.OurID;
    open cr;
    fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Prod,@Sp,@OurID
    WHILE (@@FETCH_STATUS=0) BEGIN
      if not EXISTS(select * From #t where datnom=@datnom and tekid=@tekid)
      insert into #t(datnom,tekid,ncod,ngrp,hitag,Pin,NetMode,Sell,Prod,Sp,OurID)
      VALUES(@datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Prod,@Sp,@OurID);
	  fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Prod,@Sp,@OurID
    END;
    close cr;
    deallocate cr;

    
    -- Теперь убираю продажи по запрещенным поставщикам:
    delete From #t where Ncod in (select distinct K as Ncod
      from rb_main m inner join rb_Filter f on f.RbID=m.RbID
      where m.[Active]=1 and f.tip=1 and f.RbID=@rbid);

    -- Теперь убираю продажи по запрещенным группам:
    delete from #t where ngrp in (select distinct K as Ngrp
      from rb_main m inner join rb_Filter f on f.RbID=m.RbID
      where m.[Active]=1 and f.tip=2 and f.RbID=@rbid);    

    -- Теперь убираю продажи по запрещенным товарам:
    delete from #t where Hitag in (select distinct K as Hitag
      from rb_main m inner join rb_Filter f on f.RbID=m.RbID
      where m.[Active]=1 and f.tip=3 and f.RbID=@rbid);    
    

    set @TotalSP=(select sum(SP)/1000.0 from #t)
    -- Процент бонуса я никак не найду из этих частичных продаж. Ну пусть 100%
    set @BonusPerc=100;


    insert into rb_result(rbid, rrg, comp,nd,ncod,ngrp,hitag,perc,pin,netMode,Sell,Prod,SP,OurID) 
    select 
      @rbid as rbid, @rrg as rrg, @Comp as comp, dbo.DatNomInDate(#t.datnom) as ND,#t.ncod,#t.ngrp,#t.hitag,@BonusPerc as Perc,#t.pin,
      #t.NetMode,sum(#t.Sell) Sell, sum(#t.prod) prod, sum(#t.sp) SP, #t.OurID
    from #t
    group by dbo.DatNomInDate(#t.datnom),#t.ncod,#t.ngrp,#t.hitag,#t.pin, #t.NetMode, #t.OurID;


  END; -- if (@Period0<=@day1) and (@Period1>=@Day0) and (@Active=1)


  --  drop table #t;
  
  select r.*, nm.Name
  from rb_result r inner join Nomen nm on nm.hitag=r.hitag
  where (r.comp=@Comp) and (r.rrg = @RRG);

end;