CREATE procedure CalcRetroBonus
  @day0 datetime, @day1 datetime, @RBID int, @Comp varchar(30)='it4', 
  @ClearFlag bit=1, @RRG int=0
  with recompile
as
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
declare @datnom int,@tekid int,@ncod int,@ngrp int,@hitag int,@Pin int
declare @NetMode bit,@Sell int,@Sp decimal(12,2)
declare @Koeff decimal(6,2)
declare @Treshold12 bit
declare @flgWoNds bit
declare @OurID tinyint

begin
  set @Treshold12=(select Treshold12 from rb_main where rbid=@rbid);
  if isnull(@Treshold12,0)=0 set @Koeff=-1; else set @Koeff=1.12;

  if (@RRG>0) and (@ClearFlag=1) delete From rb_result where RRG=@RRG;
  if (@RRG=0) and (@ClearFlag=1) delete From rb_result where Comp=@Comp and RRG=0;
  
  select @period0=m.StartDay, @Period1=m.FinishDay, @PayBySell=m.PayBySell, 
    @Active=m.Active, @flgWoNds=m.flgWoNds
  From rb_main m where m.rbid=@RBID;

  -- создаю таблицу продаж, с указанием накладной и товара:
  create table #t (Datnom int, Tekid int, 
    Ncod int, Ngrp int,  hitag int, 
    pin int,  NetMode Bit, Sell int, SP decimal(12,2), OurID tinyint);
    
  if (@Period0<=@day1) and (@Period1>=@Day0) and (@Active=1) BEGIN
    set @n0=dbo.InDatNom(1, @day0)
    set @n1=dbo.InDatNom(9999, @day1)
    set @n10=dbo.InDatNom(1, @period0)
    set @n20=dbo.InDatNom(9999, @period1)
    
    -- Есть ли фильтры с полной номенклатурой? Вообще полной
    -- Вычеркнуто: "или за исключением какого-то поставщика, группы или товара"
    if exists(select * from rb_Filter where rbid=@rbid and tip=0)
    insert into #t(datnom, tekid, ncod, ngrp, hitag,pin,netmode,sell,sp, OurID)
    select 
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp, NV.hitag, 
      nc.B_ID as pin, b.NetMode, sum(nv.Kol) as Sell, 
      sum(nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as SP,
      nc.OurID
    From 
      nv inner join nc on nc.datnom=nv.datnom
      inner join Def D on D.pin=nc.B_ID and d.tip=1
      inner join rb_buyers b on b.Pin=D.Pin or (b.NetMode=1 and b.Pin=D.[Master])
      inner join rb_main m on m.RbID=b.rbid
      inner join Nomen nm on nm.hitag=nv.hitag
      inner join gr on gr.Ngrp=nm.ngrp
      inner join visual vi on vi.id=nv.TekID
    where 
      b.RbId=@RBID
      and nv.datnom between @n0 and @n1 -- период расчета
      and nv.datnom between @n10 and @n20 -- период действия фильтра
      and nv.Kol<>0
      and m.[Active]=1
      and (nv.price*(1.0+nc.extra/100)>=@koeff*nv.Cost or gr.MainParent=3)
      and nc.Actn=0
    group by
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp, NV.hitag, nc.B_ID, b.NetMode, nc.OurID;
    
    create index t_idx_ndtekid on #t(datnom,tekid);

    -- Теперь дописываю продажи всего по указанным поставщикам,
    -- но избегаю дубликатов:
    declare cr cursor fast_forward for select 
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp,
      NV.hitag, 
      nc.B_ID as pin, b.NetMode, sum(nv.Kol) as Sell, 
      sum(nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as SP,
      nc.OurID
    From 
      nv inner join nc on nc.datnom=nv.datnom
      inner join Def D on D.pin=nc.B_ID and d.tip=1
      inner join rb_buyers b on b.Pin=D.Pin or (b.NetMode=1 and b.Pin=D.[Master])
      inner join rb_main m on m.RbID=b.rbid
      inner join Visual Vi on vi.id=nv.TekID    
      inner join rb_filter f on f.RbID=m.RbID and f.tip=4 and f.k=vi.ncod
      inner join Nomen nm on nm.hitag=nv.hitag
      inner join gr on gr.Ngrp=nm.ngrp
    where 
      nv.datnom between @n0 and @n1
      and nv.datnom between @n10 and @n20 --  and nc.nd between m.StartDay and m.FinishDay
      and nv.Kol<>0
      and m.[Active]=1
      and m.RbID=@RBID
      and (nv.price*(1.0+nc.extra/100)>=@koeff*nv.Cost or gr.MainParent=3)
      and nc.Actn=0
    group by
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp, NV.hitag, nc.B_ID, b.NetMode,nc.OurID;
    open cr;
    fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Sp,@OurID
    WHILE (@@FETCH_STATUS=0)  BEGIN
      if not EXISTS(select * From #t where datnom=@datnom and tekid=@tekid)
      insert into #t(datnom,tekid,ncod,ngrp,hitag,Pin,NetMode,Sell,Sp, OurID)
      VALUES(@datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Sp, @OurID);
	  fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Sp, @OurID;
    END;
    close cr;
    deallocate cr;

  
    
    -- Теперь продажи всего по указанным группам товаров:
    declare cr cursor fast_forward for select 
      nv.DatNom, nv.tekid, vi.ncod, nm.ngrp,
      NV.hitag, 
      nc.B_ID as pin, b.NetMode, sum(nv.Kol) as Sell, 
      sum(nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as SP,
      nc.OurID
    From 
      nv inner join nc on nc.datnom=nv.datnom
      inner join Def D on D.pin=nc.B_ID and d.tip=1
      inner join rb_buyers b on b.Pin=D.Pin or (b.NetMode=1 and b.Pin=D.[Master])
      inner join rb_main m on m.RbID=b.rbid
      inner join Nomen NM on NM.Hitag=nv.Hitag
      inner join gr on gr.Ngrp=nm.ngrp
      inner join rb_filter f on f.RbID=m.RbID and f.tip=5 and nm.Ngrp=f.K
      inner join Visual Vi on vi.id=nv.TekID    
    where 
      nv.datnom between @n0 and @n1
      and nv.datnom between @n10 and @n20 -- and nc.nd between m.StartDay and m.FinishDay
      and nv.Kol<>0
      and m.[Active]=1
      and m.RbID=@RBID
      and (nv.price*(1.0+nc.extra/100)>=@Koeff*nv.Cost or gr.MainParent=3)
      and nc.Actn=0
    group by
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp, NV.hitag, nc.B_ID, b.NetMode, nc.OurID;
    open cr;
    fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Sp,@OurID
    WHILE (@@FETCH_STATUS=0)  BEGIN
      if not EXISTS(select * From #t where datnom=@datnom and tekid=@tekid)
        insert into #t(datnom,tekid,ncod,ngrp,hitag,Pin,NetMode,Sell,Sp,OurID)
        VALUES(@datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Sp,@OurID);
	  fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Sp,@OurID;
    END;
    close cr;
    deallocate cr;

    -- Теперь продажи всего по указанным кодам товаров:

    declare cr cursor fast_forward for select 
      nv.DatNom, nv.tekid, vi.ncod, nm.ngrp,
      NV.hitag, 
      nc.B_ID as pin, b.NetMode, sum(nv.Kol) as Sell, 
      sum(nv.Kol*nv.price*(case when @flgWoNds=1 then 100.0/(100+nm.nds) else 1 end)*(1.0+nc.extra/100)) as SP,
      nc.OurID
    From 
      nv inner join nc on nc.datnom=nv.datnom
      inner join Def D on D.pin=nc.B_ID and d.tip=1
      inner join rb_buyers b on b.Pin=D.Pin or (b.NetMode=1 and b.Pin=D.[Master])
      inner join rb_main m on m.RbID=b.rbid
      inner join Nomen NM on NM.Hitag=nv.Hitag
      inner join gr on gr.Ngrp=nm.ngrp
      inner join rb_filter f on f.RbID=m.RbID and f.tip=6 and nv.hitag=f.K
      inner join Visual Vi on vi.id=nv.TekID    
    where 
      nv.datnom between @n0 and @n1
      and nv.datnom between @n10 and @n20 -- and nc.nd between m.StartDay and m.FinishDay
      and nv.Kol<>0    
      and m.[Active]=1
      and m.RbID=@RBID
      and (nv.price*(1.0+nc.extra/100)>=@koeff*nv.Cost or gr.MainParent=3)
      and nc.Actn=0
    group by
      nv.datnom, nv.tekid, vi.ncod, nm.ngrp, NV.hitag, nc.B_ID, b.NetMode, nc.OurID;
    open cr;
    fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Sp,@OurID
    WHILE (@@FETCH_STATUS=0) BEGIN
      if not EXISTS(select * From #t where datnom=@datnom and tekid=@tekid)
      insert into #t(datnom,tekid,ncod,ngrp,hitag,Pin,NetMode,Sell,Sp,OurID)
      VALUES(@datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Sp,@OurID);
	  fetch next From cr into @datnom,@tekid,@ncod,@ngrp,@hitag,@Pin,@NetMode,@Sell,@Sp,@OurID;
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

    -- Ищу процент бонуса в таблице с кусочно-линейной аппроксимацией:
    set @TotalSP=(select sum(SP)/1000.0 from #t)
    set @BonusPerc=(select Perc from RB_Percent where RbID=@RbId and @TotalSP>=Level0 and @TotalSP<Level1)

    
    insert into rb_result(rbid, rrg, comp,nd,ncod,ngrp,hitag,perc,pin,netMode,Sell,Prod,SP, OurID) 
    select 
      @rbid as rbid, @rrg as rrg, @Comp as comp, dbo.DatNomInDate(#t.datnom) as ND,#t.ncod,#t.ngrp,#t.hitag,@BonusPerc as Perc,#t.pin,
      #t.NetMode,sum(#t.Sell) Sell, sum(#t.sp) SP, sum(#t.sp) Prod, #t.OurID
    from #t
    group by dbo.DatNomInDate(#t.datnom),#t.ncod,#t.ngrp,#t.hitag,#t.pin, #t.NetMode, #t.OurID;

  END; -- if (@Period0<=@day1) and (@Period1>=@Day0) and (@Active=1)
  
  drop table #t;
  
  select r.*, nm.Name
  from rb_result r inner join Nomen nm on nm.hitag=r.hitag
  where r.comp=@Comp and rrg=@rrg
  order by r.hitag, r.ND
  
end;