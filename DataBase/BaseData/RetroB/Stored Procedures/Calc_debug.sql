

CREATE procedure retrob.Calc_debug
  @day0 datetime, @day1 datetime, 
  @VedID int,  @RBID int, @Comp varchar(30)='it4', 
  @ClearFlag bit=1
  with recompile
as
declare @BonusPerc decimal(12,2), @rawid int,
    @PayBySell bit,
    @n0 int, @n1 int, @n10 int, @n20 int,
    @TekNcod int,
    @TekNgrp int,
    @TekHitag int,
    @Period0 datetime,
    @Period1 datetime,
    @TotalSP decimal(12,2),
    @Active bit,
    @datnom int,@tekid int,@ncod int,@ngrp int,@hitag int,@Pin int,
    @NetMode bit,@Sell int,@Sp decimal(15,5), @Tot decimal(15,2), @Rez decimal(15,2),
    @RatePerc decimal(6,2), @Koeff decimal(6,2),
    @flgWoNds bit,
    @OurID tinyint,
    @FoundFilterExistsVendors bit, @FoundFilterDisabVendors bit,
    @FoundFullNomenFilter bit,
    @FoundPartialNomenFilter bit,
    @FoundNomenDisabFilter bit,
    @FirstNnak int, @LastNnak int


-- Эта процедура вызывается один раз для каждого отдельного 
-- ретробонуса номер @RBID  в ведомости номер @VedID:

begin
truncate table retrob.log;
-- delete from retrob.Rb_RAWdet where VedID=@VedID and rbid=@rbid;
set @FirstNnak=dbo.InDatNom(1,@day0)
set @LastNnak=dbo.InDatNom(9999,@day1)
  
if EXISTS(select * from retrob.rb_Main where Active=1 and rbid=@rbid) begin

  set @RatePerc=(select RatePerc from retrob.rb_main where RbID=@rbid)
  if isnull(@RatePerc,0)=0 set @Koeff=-1; else set @Koeff=1.0+0.01*@RatePerc;
  
  select @period0=m.StartDay, @Period1=m.FinishDay, @PayBySell=m.PayBySell, 
    @Active=m.Active, @flgWoNds=m.flgWoNds
  From retrob.rb_main m where m.rbid=@RBID;

  -- Исходные данные уже находятся в таблице retrob.rb_RAW, там и товары, и данные поставщиков и покупателей.
  
  -- Вот в эту таблицу будем загонять информацию о товарах, удовлетворяющих требованиям фильтров:
  create table #t (RawID int, SP decimal(15,5), VendorOK bit default 1, NomenOk bit default 1);
  -- А в эту - о поставщиках:
  create table #v (rawid int);

    
  if (@Period0<=@day1) and (@Period1>=@Day0) and (@Active=1) BEGIN
    set @n0=dbo.InDatNom(1, @day0)
    set @n1=dbo.InDatNom(9999, @day1)
    set @n10=dbo.InDatNom(1, @period0)
    set @n20=dbo.InDatNom(9999, @period1)
    
    
    IF @PAYBYSELL=1 BEGIN
        --*******************************************************************************************************************
        --*   РАСЧЕТ ОТ ПРОДАЖ																								*
        --*******************************************************************************************************************
        -- Нужно ли найти продажи для каких-либо покупателей? На поставщиков пока не смотрим.
        -- Сюда не попадут продажи за пределами интервала, и возвраты тоже, и слишком дешевые.
        insert into RetroB.log(MESS) values('Paybysell=1');
        if exists(select * from retrob.rb_Buyers where rbid=@rbid and Pin>0) begin
          insert into RetroB.log(MESS) values('Есть разрешающий фильтр для покупателей');
          insert into #t(RawID, sp)
          select 
            R.RawID, r.Kol*r.price*(case when @flgWoNds=1 then 100.0/(100+r.nds) else 1 end) as SP
          From 
            retrob.rb_raw r
            inner join retrob.rb_buyers b on b.Pin=r.b_id or (b.NetMode=1 and b.Pin=r.[Master]) 
          where 
            r.vedid=@VedID
            and b.RbId=@RBID
            and (r.price>=@koeff*r.Cost or r.MainParent=3)
            and r.datnom between @FirstNnak and @LastNnak
        end;
        else begin -- если же фильтр по покупателям не задан, то забираем вообще все продажи:
          insert into RetroB.log(MESS) values('Нет разрешающего фильтра для покупателей');
          insert into #t(RawID, sp)
          select 
            R.RawID, r.Kol*r.price*(case when @flgWoNds=1 then 100.0/(100+r.nds) else 1 end) as SP
          From 
            retrob.rb_raw r
          where 
            r.vedid=@VedID
            and (r.price>=@koeff*r.Cost or r.MainParent=3)
            and r.datnom between @FirstNnak and @LastNnak
		end;
        
        create index t_idx_rawid on #t(rawid);

        -- ТЕПЕРЬ ПОСТАВЩИКИ. Варианты такие: 
        -- либо поставщики не оговорены (тогда и делать ничего не надо)
        -- либо задан список нужных поставщиков (тогда всех прочих надо вычеркнуть)
        -- либо задан список исключаемых поставщиков (тогда только их оставить).
        -- Возможна коллизия: например, по одному условию все поставщики, по другому только 100-й.
        -- Нет, считаем, такая возможность заранее исключена.

        -- Итак, есть ли фильтр продаж по списку разрешенных поставщиков?
        set @FoundFilterExistsVendors=0; -- для начала считаем, что нет.
        
        -- А теперь дергаем список товаров по разрешенным поставщикам:
        
        insert into #v  select distinct r.rawid
        from 
          retrob.rb_raw r
          inner join retrob.rb_filter f on f.tip=4 and f.k=r.ncod 
        where 
          RbID=@RbID
          and (r.price>=@koeff*r.Cost or r.MainParent=3);
        if exists(select * from #v) begin
          set @FoundFilterExistsVendors=1;
          insert into RetroB.log(MESS) values('Есть разрешающий фильтр для поставщиков');          
          create index v_temp_idx on #v(rawid);
          update #t set VendorOK=0;
          update #t set VendorOK=1 where rawid in (select rawid from #v);
          truncate table #v;
          delete from #t where VendorOK=0;
          -- select distinct r.ncod from #t inner join retrob.rb_raw r on r.rawid=#t.rawid;
        end;
        
        -- Если нет фильтра по разрешенным, тогда, может быть, есть фильтр по запрещенным?
        if @FoundFilterExistsVendors=0 begin
          insert into RetroB.log(MESS) values('Нет разрешающего фильтрф\а для поставщиков');          
          set @FoundFilterDisabVendors=0;
          update #t set VendorOK=1;	   
          insert into #v  select distinct r.rawid
          from 
            retrob.rb_raw r
            inner join retrob.rb_filter f on f.tip=1 and f.k=r.ncod -- tip=1 соотв. запрету
          where 
            f.RbID=@RbID
            and (r.price>=@koeff*r.Cost or r.MainParent=3);
          if exists(select * from #v) begin
            insert into RetroB.log(MESS) values('Есть запрещающий фильтр для поставщиков');          
            set @FoundFilterDisabVendors=1;
            create index v_temp_idx on #v(rawid);
            update #t set VendorOK=0 where rawid in (select rawid from #v);
            truncate table #v;
            delete from #t where VendorOK=0;
          end;
        end;
        

        -- **************************************
        -- ТЕПЕРЬ НОМЕНКЛАТУРА.
        -- **************************************
        -- Есть ли частичные разрешающие фильтры?
          if EXISTS( select * from retrob.rb_filter f where f.RbID=@RbID and f.tip in (5,6))
          set @FoundPartialNomenFilter=1;
          else set @FoundPartialNomenFilter=0;
          
          -- Если есть частичные разрешающие фильтры, отработаем их:
          if @FoundPartialNomenFilter=1
          begin
            insert into RetroB.log(MESS) values('есть частичные разрешающие фильтры по товарам');          
            update #t set NomenOK=0;
            update #t set NomenOK=1 where RawID in (
              select distinct r.rawid 
              from 
                Retrob.rb_raw r
                inner join retrob.rb_filter f on f.k=r.hitag
              where 
                f.RbID=@RbID
                and (r.price>=@koeff*r.Cost or r.MainParent=3)
                and f.tip=6
            );
            update #t set NomenOK=1 where RawID in (
              select distinct r.rawid 
              from 
                Retrob.rb_raw r
                inner join retrob.rb_filter f on (f.k=r.ngrp or f.k=r.MainParent)
              where 
                f.tip=5
                and f.RbID=@RbID
                and (r.price>=@koeff*r.Cost or r.MainParent=3)
            );
          end; --  А если нет частичных разрешающих фильтров, значит, разрешена вся номенклатура:
          else 
            update #t set NomenOK=1 where RawID in (
              select distinct r.rawid 
              from 
                Retrob.rb_raw r
              where 
                (r.price>=@koeff*r.Cost or r.MainParent=3)
            );
          
          
        -- Есть ли какие-то запрещающие фильтры по номенклатуре?
        if exists(select * from retrob.rb_filter f where f.RbID=@RbID and f.tip in (2,3))
        begin  -- собственно поиск запрещенных групп и товаров:
          insert into RetroB.log(MESS) values('есть частичные запрещающие фильтры по товарам');          
          update #t set NomenOK=0 where RawID in (
            select r.rawid 
            from 
              Retrob.rb_raw r
              inner join retrob.rb_filter f on f.k=r.hitag
            where 
              f.RbID=@RbID
              and f.tip=3
          );
          update #t set NomenOK=0 where RawID in (
            select distinct r.rawid 
            from 
              Retrob.rb_raw r
              inner join retrob.rb_filter f on (f.k=r.ngrp or f.k=r.MainParent)
            where 
              f.tip=2
              and f.RbID=@RbID
          );
          select count(*) as BadTov from #t where NomenOK=0;
        end;
--        select * from #t;
--        select sum(sp) from #t where nomenok=1;
--        return;
        
        -- Ищу процент бонуса в таблице с кусочно-линейной аппроксимацией:
        set @Tot=(select sum(isnull(SP,0)) from #t where VendorOK=1 and NomenOK=1);
        set @TotalSP=@Tot/1000;
        set @BonusPerc=(select Perc from retrob.RB_Percent where RbID=@RbId and @TotalSP>=Level0 and @TotalSP<Level1);
        -- Итак, сумма бонуса составляет @BonusPerc (например, 5%) от суммы продаж @Tot.
        -- Значит, что? Значит, нужно это дело сохранить.
        -- То есть в табл. rb_RawDet выписать строчки из rb_raw, которые относятся именно к расчету @vedid:
/*        insert into retrob.rb_rawdet(rawid, vedid, rbid, [bonus])
        select
          r.rawid, @vedid, @rbid, #t.sp*@BonusPerc/100.0
        from 
          retrob.rb_raw r
          inner join #t on #t.rawid=r.rawid
        where 
          r.vedID=@VedID and #t.VendorOK=1 and #t.NomenOK=1;
*/          
        drop table #t;
        
    end;





    else begin
        --*******************************************************************************************************************
        --*   РАСЧЕТ ОТ ОПЛАТЫ																								*
        --*******************************************************************************************************************
        -- Нужно ли найти продажи для каких-либо покупателей? На поставщиков пока не смотрим.
        -- Сюда не попадут продажи за пределами интервала, и слишком дешевые. А возвраты попадут.
        if exists(select * from retrob.rb_Buyers where rbid=@rbid and Pin>0)
          insert into #t(RawID, sp)
          select 
            R.RawID, r.PayKoeff*r.Kol*r.price*(case when @flgWoNds=1 then 100.0/(100+r.nds) else 1 end) as SP
          From 
            retrob.rb_raw r
            inner join retrob.rb_buyers b on b.Pin=r.b_id or (b.NetMode=1 and b.Pin=r.[Master]) 
          where 
            r.vedid=@VedID
            and b.RbId=@RBID
            and (r.price>=@koeff*r.Cost or r.MainParent=3)
            and r.PayKoeff<>0;
        else -- если же фильтр по покупателям не задан, то забираем вообще все продажи:
          insert into #t(RawID, sp)
          select 
            R.RawID, r.PayKoeff*r.Kol*r.price*(case when @flgWoNds=1 then 100.0/(100+r.nds) else 1 end) as SP
          From 
            retrob.rb_raw r
          where 
            r.vedid=@VedID
            and (r.price>=@koeff*r.Cost or r.MainParent=3)
            and r.PayKoeff<>0;

        create index t_idx_rawid on #t(rawid);

        -- ТЕПЕРЬ ПОСТАВЩИКИ. Варианты такие: 
        -- либо поставщики не оговорены (тогда и делать ничего не надо)
        -- либо задан список нужных поставщиков (тогда всех прочих надо вычеркнуть)
        -- либо задан список исключаемых поставщиков (тогда только их оставить).
        -- Возможна коллизия: например, по одному условию все поставщики, по другому только 100-й.
        -- Нет, считаем, такая возможность заранее исключена.

        -- Итак, есть ли фильтр продаж по списку разрешенных поставщиков?
        set @FoundFilterExistsVendors=0; -- для начала считаем, что нет.
        
        -- А теперь дергаем список товаров по разрешенным поставщикам:
        insert into #v  select distinct r.rawid
        from 
          retrob.rb_raw r
          inner join retrob.rb_filter f on f.tip=4 and f.k=r.ncod 
        where 
          f.RbID=@RbID
          and (r.price>=@koeff*r.Cost or r.MainParent=3)
          and r.PayKoeff<>0;
        if exists(select * from #v) begin
          set @FoundFilterExistsVendors=1;
          create index v_temp_idx on #v(rawid);
          update #t set VendorOK=0;
          update #t set VendorOK=1 where rawid in (select rawid from #v);
          truncate table #v;
          delete from #t where VendorOK=0;
          -- select distinct r.ncod from #t inner join retrob.rb_raw r on r.rawid=#t.rawid;
        end;
        
        -- Если нет фильтра по разрешенным, тогда, может быть, есть фильтр по запрещенным?
        if @FoundFilterExistsVendors=0 begin
          set @FoundFilterDisabVendors=0;
          update #t set VendorOK=1;	   
          insert into #v  select distinct r.rawid
          from 
            retrob.rb_raw r
            inner join retrob.rb_filter f on f.tip=1 and f.k=r.ncod -- tip=1 соотв. запрету
          where 
            f.RbID=@RbID
            and (r.price>=@koeff*r.Cost or r.MainParent=3)
            and r.PayKoeff<>0;
          if exists(select * from #v) begin
            set @FoundFilterDisabVendors=1;
            create index v_temp_idx on #v(rawid);
            update #t set VendorOK=0 where rawid in (select rawid from #v);
            -- select r.* from #v inner join retrob.rb_raw r on r.rawid=#v.rawid inner join #t on #t.rawid=r.rawid;
            truncate table #v;
            delete from #t where VendorOK=0;
          end;
        end;
        

        -- **************************************
        -- ТЕПЕРЬ НОМЕНКЛАТУРА.
        -- **************************************
        -- Есть ли частичные разрешающие фильтры?
          if EXISTS( select * from retrob.rb_filter f where f.RbID=@RbID and f.tip in (5,6))
          set @FoundPartialNomenFilter=1;
          else set @FoundPartialNomenFilter=0;
          
          -- Если есть частичные разрешающие фильтры, отработаем их:
          if @FoundPartialNomenFilter=1
          begin
            update #t set NomenOK=0;
            update #t set NomenOK=1 where RawID in (
              select distinct r.rawid 
              from 
                Retrob.rb_raw r
                inner join retrob.rb_filter f on f.k=r.hitag
              where 
                f.RbID=@RbID
                and (r.price>=@koeff*r.Cost or r.MainParent=3)
                and f.tip=6
		        and r.PayKoeff<>0
            );
            update #t set NomenOK=1 where RawID in (
              select distinct r.rawid 
              from 
                Retrob.rb_raw r
                inner join retrob.rb_filter f on (f.k=r.ngrp or f.k=r.MainParent)
              where 
                f.tip=5
                and f.RbID=@RbID
                and (r.price>=@koeff*r.Cost or r.MainParent=3)
		        and r.PayKoeff<>0
            );
          end; --  А если нет частичных разрешающих фильтров, значит, разрешена вся номенклатура:
          else 
            update #t set NomenOK=1 where RawID in (
              select distinct r.rawid 
              from 
                Retrob.rb_raw r
              where 
                (r.price>=@koeff*r.Cost or r.MainParent=3)
                and r.PayKoeff<>0
            );
          
          
        -- Есть ли какие-то запрещающие фильтры по номенклатуре?
        if exists(select * from retrob.rb_filter f where f.RbID=@RbID and f.tip in (2,3))
        begin  -- собственно поиск запрещенных групп и товаров:
          update #t set NomenOK=0 where RawID in (
            select r.rawid 
            from 
              Retrob.rb_raw r
              inner join retrob.rb_filter f on f.k=r.hitag
            where 
              f.RbID=@RbID
              and f.tip=3
          );
          update #t set NomenOK=0 where RawID in (
            select distinct r.rawid 
            from 
              Retrob.rb_raw r
              inner join retrob.rb_filter f on (f.k=r.ngrp or f.k=r.MainParent)
            where 
              f.tip=2
              and f.RbID=@RbID
          );
        end;
        
        -- Ищу процент бонуса в таблице с кусочно-линейной аппроксимацией:
        set @Tot=(select sum(isnull(SP,0)) from #t where VendorOK=1 and NomenOK=1);
        set @TotalSP=@Tot/1000;
        set @BonusPerc=(select Perc from retrob.RB_Percent where RbID=@RbId and @TotalSP>=Level0 and @TotalSP<Level1);
        -- Итак, сумма бонуса составляет @BonusPerc (например, 5%) от суммы продаж @Tot.
        -- Значит, что? Значит, нужно это дело сохранить.
        -- То есть в табл. rb_RawDet выписать строчки из rb_raw, которые относятся именно к расчету @vedid:
--        insert into retrob.rb_rawdet(rawid, vedid, rbid, [bonus])
        select
          r.rawid, @vedid, @rbid, #t.sp*@BonusPerc/100.0
        from 
          retrob.rb_raw r
          inner join #t on #t.rawid=r.rawid
        where 
          r.vedID=@VedID and #t.VendorOK=1 and #t.NomenOK=1;
          
        
        drop table #t;
    end;    
  END; -- if (@Period0<=@day1) and (@Period1>=@Day0) and (@Active=1)
  
  --  select r.*, nm.Name
  --  from retrob.rb_result r inner join Nomen nm on nm.hitag=r.hitag
  --  where r.comp=@Comp and rrg=@rrg;
end;
end;