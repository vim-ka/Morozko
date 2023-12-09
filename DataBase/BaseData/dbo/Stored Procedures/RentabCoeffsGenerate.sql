CREATE PROCEDURE dbo.RentabCoeffsGenerate 
@year int, @month int
AS
BEGIN
  declare @bd_dn int
  declare @ed_dn int
  declare @type_id int
  declare @hitag int
  declare @val numeric(10, 3)
  declare @ngrp int
  declare @ncod int
  declare @bd datetime
  declare @ed datetime
  declare @cost numeric(10, 3)
  declare @price numeric(10, 3) 
  declare @ym varchar(6)
  declare @year_month int 
  declare @vedid int
  declare @s2id int
  declare @salkopl numeric(12, 3)
  declare @ncopl numeric(12, 3)  
  declare @torgtsum numeric(12, 3)
  declare @cnttvs int  
  declare @torgtkg numeric(12, 3)
  declare @torgtr_kg numeric(12, 3)
  
  set @bd = convert(datetime, '01.' + convert(varchar(2), @month) + '.' + convert(varchar(4), @year), 104)
  select @ed = convert(datetime, EOMONTH(convert(datetime, '01.' + convert(varchar(2), @month) + '.' + convert(varchar(4), @year)), 0), 104)
  
  if @month < 10
  	set @ym = convert(varchar(4), @year) + '0' + convert(varchar(2), @month)
  else
    set @ym = convert(varchar(4), @year) + convert(varchar(2), @month)
  
  set @year_month = convert(int, @ym)
  
  set @bd_dn = dbo.InDatNom(0000, @bd)
  set @ed_dn = dbo.InDatNom(9999, @ed)  

  create table #tvs(hitag int);
  insert into #tvs select a.hitag
  from morozarc..arcvi a inner join dbo.nomen n on n.hitag = a.hitag
  where a.workdate between @bd and @ed
  and n.closed = 0 and n.inactive = 0
  and n.ngrp not in (0, 2, 10, 12, 13, 19, 21, 25, 90)
  group by a.hitag 
  
--  TRUNCATE table dbo.RentabCoeffs --отладка
  delete from dbo.RentabCoeffs where year_month = @year_month
  
  DECLARE prs CURSOR FAST_FORWARD FOR
  select a.hitag,
	case when sum(a.MornRest) = 0 then sum(a.cost * a.mornrest) else sum(a.cost * a.mornrest) / sum(a.MornRest) end cost_,
	case when sum(a.MornRest) = 0 then sum(a.price * a.mornrest) else sum(a.price * a.mornrest) / sum(a.MornRest) end price_
	from morozarc..arcvi a inner join dbo.nomen n on n.hitag = a.hitag
	where a.workdate between @bd and @ed
	and n.closed = 0 and n.inactive = 0
	and n.ngrp not in (0, 2, 10, 12, 13, 19, 21, 25, 90)
	group by a.hitag
  
  select @torgtsum = abs(sum(k.plata)) from dbo.kassa1 k where k.Oper = 39 and k.nd between @bd and @ed and k.plata < 0
  select @torgtkg = sum(IIF(v.weight = 0, n.Netto, v.weight) * dbo.nv.kol) from dbo.nv
  inner join dbo.nomen n on n.hitag = dbo.nv.hitag
  inner join dbo.visual v on v.id = dbo.nv.TekID
  inner join (select hitag from #tvs) t on t.hitag = n.hitag
  
  --print @torgtsum
  --print @torgtkg
  
  declare torgt cursor fast_forward for
  select t.hitag, @torgtsum * (sum(IIF(v.weight = 0, n.Netto, v.weight) * dbo.nv.kol) / @torgtkg)
  from dbo.nv
  inner join dbo.nomen n on n.hitag = dbo.nv.hitag
  inner join dbo.visual v on v.id = dbo.nv.TekID
  inner join (select hitag from #tvs) t on t.hitag = n.hitag
  where dbo.nv.DatNom BETWEEN @bd_dn and @ed_dn
  and dbo.NV.Kol > 0
  group by t.hitag
  having sum(IIF(v.weight = 0, n.Netto, v.weight) * dbo.nv.kol) > 0
    
  declare tovs cursor fast_forward for
  select hitag from #tvs
/*  select a.hitag
	from morozarc..arcvi a inner join dbo.nomen n on n.hitag = a.hitag
	where a.workdate between @bd and @ed
	and n.closed = 0 and n.inactive = 0
	and n.ngrp not in (0, 2, 10, 12, 13, 19, 21, 25, 90)
	group by a.hitag*/
    
  declare cstore cursor fast_forward for
  select a.hitag, n.ngrp, max(g.Cost1kgStor)
	from morozarc..arcvi a inner join dbo.nomen n on n.hitag = a.hitag
    inner join dbo.gr g on g.Ngrp = n.ngrp
	where a.workdate between @bd and @ed
	and n.closed = 0 and n.inactive = 0
	and n.ngrp not in (0, 2, 10, 12, 13, 19, 21, 25, 90)
	group by a.hitag, n.ngrp    
    
  DECLARE cur_type CURSOR FAST_FORWARD FOR 
  select fct.id
  from dbo.RentabCalcTypes fct
  where fct.active = 1

  begin try
    OPEN cur_type
    FETCH NEXT FROM cur_type into @type_id
    WHILE @@FETCH_STATUS = 0
    BEGIN
      --print @type_id
      if @type_id = 1 --закупка
      begin
      	OPEN prs;
		FETCH NEXT FROM prs into @hitag, @cost, @price;
		WHILE @@FETCH_STATUS = 0
		BEGIN
          insert into dbo.RentabCoeffs(year_month, hitag, type, val, ncod) values(@year_month, @hitag, @type_id, @cost, null)
          --print @hitag
	      FETCH NEXT FROM prs into @hitag, @cost, @price;
	    END;
        CLOSE prs;
      end
      
      if @type_id = 2 --продажа
      begin
      	--print 'type_id 2'
        OPEN prs;
		FETCH NEXT FROM prs into @hitag, @cost, @price;
		WHILE @@FETCH_STATUS = 0
		BEGIN
          insert into dbo.RentabCoeffs(year_month, hitag, type, val, ncod) values(@year_month, @hitag, @type_id, @price, null)
          --print @hitag
	      FETCH NEXT FROM prs into @hitag, @cost, @price;
	    END;
        CLOSE prs;
      end
      
/*      if @type_id = 3 --торговая наценка -- не заполнять, расчетная величина
      begin
      	--
      end*/
      
      if @type_id = 4 --расходы на присутствие в торговых точках
      begin
        OPEN torgt;
		FETCH NEXT FROM torgt into @hitag, @torgtr_kg;
		WHILE @@FETCH_STATUS = 0
		BEGIN
          insert into dbo.RentabCoeffs(year_month, hitag, type, val, ncod) values(@year_month, @hitag, @type_id, @torgtr_kg, null)
          FETCH NEXT FROM torgt into @hitag, @torgtr_kg;
	    END;
        CLOSE torgt;
      end
      
      /*if @type_id = 5 --плата за установку торгового оборудования
      begin
      	--
      end*/
      
      if @type_id = 6 --ретробонус
      begin
      	select @vedid = rbv.vedid from RetroB.rb_Vedom rbv where rbv.day0 = @bd and rbv.day1 = @ed
        
        insert into dbo.RentabCoeffs(year_month, hitag, type, val, ncod) 
        select @year_month, rbr.Hitag, @type_id, sum(rrd.Bonus) / iif(sum(IIF(v.weight = 0, n.Netto, v.weight) * rbr.kol) = 0, 1, sum(IIF(v.weight = 0, n.Netto, v.weight) * rbr.kol)), null
		from RetroB.Rb_RAW rbr
		inner join RetroB.rb_RawDet rrd on rrd.rawID = rbr.rawID
		inner join dbo.Visual v on v.id = rbr.tekid
		inner join dbo.nomen n on n.hitag = v.hitag
		where rbr.vedID = @vedid
        and rbr.hitag in (select hitag from #tvs)
		group by rbr.hitag
		having sum(rrd.Bonus) / iif(sum(IIF(v.weight = 0, n.Netto, v.weight) * rbr.kol) = 0, 1, sum(IIF(v.weight = 0, n.Netto, v.weight) * rbr.kol)) > 0
      end
      
/*      if @type_id = 7 --расходы на закупку на центральный склад в г. Воронеж --дальняя логистика
      begin
      	--
      end*/

      if @type_id = 8 --расходы на хранение в центральном складе г. Воронеж
      begin
      	OPEN cstore;
		FETCH NEXT FROM cstore into @hitag, @ngrp, @cost;
		WHILE @@FETCH_STATUS = 0
		BEGIN
          insert into dbo.RentabCoeffs(year_month, hitag, type, val, ncod) values(@year_month, @hitag, @type_id, @cost, null)
          --print @hitag
	      FETCH NEXT FROM cstore into @hitag, @ngrp, @cost;
	    END;
        CLOSE cstore;
      end
      
      if @type_id = 9 --расходы на доставку в транзитный склад в г. Севастополь
      begin
      	OPEN tovs;
		FETCH NEXT FROM tovs into @hitag;
		WHILE @@FETCH_STATUS = 0
		BEGIN
	      insert into dbo.RentabCoeffs(year_month, hitag, type, val, ncod) values(@year_month, @hitag, @type_id, 10.0, null)
          FETCH NEXT FROM tovs into @hitag;
	    END;
        CLOSE tovs;
      end

/*      if @type_id = 10 --расходы на доставку до покупателя на территории АО Крым (з/п водителя, ГСМ, ТО и ремонт авто, страхование)
      begin
      	--
      end

      if @type_id = 11 --расходы на содержание обособленного подразделения в г. Ялта (аренда, коммунальные расходы, офисные расходы)
      begin
      	--
      end*/

      if @type_id = 12 --расходы на администрирование, управление и финансовое обеспечение в г. Воронеж
      begin
      	OPEN tovs;
		FETCH NEXT FROM tovs into @hitag;
		WHILE @@FETCH_STATUS = 0
		BEGIN
	      insert into dbo.RentabCoeffs(year_month, hitag, type, val, ncod) values(@year_month, @hitag, @type_id, 4.5, null)
          FETCH NEXT FROM tovs into @hitag;
	    END;
        CLOSE tovs;
      end

      if @type_id = 13 --расходы на оплату труда торгового персонала (супервайзер, ТА, мерчендайзер)
      begin
      	select @s2id = sm.s2id from Salary.Salary2main sm where sm.day0 = @bd and sm.day1 = @ed and sm.Cancelled = 0
        select @salkopl = sum(sr.Kopl) from Salary.Salary2result sr where sr.s2id = @s2id
        select @ncopl = sum(IIF(v.weight = 0, n.Netto, v.weight) * dbo.nv.kol) from dbo.nv
		inner join dbo.nomen n on n.hitag = dbo.nv.hitag
		inner join dbo.visual v on v.id = dbo.nv.TekID
		where
		dbo.nv.DatNom BETWEEN @bd_dn and @ed_dn
		and dbo.NV.Kol > 0
        
        OPEN tovs;
		FETCH NEXT FROM tovs into @hitag;
		WHILE @@FETCH_STATUS = 0
		BEGIN
	      insert into dbo.RentabCoeffs(year_month, hitag, type, val, ncod) values(@year_month, @hitag, @type_id, @ncopl / @salkopl, null)
          FETCH NEXT FROM tovs into @hitag;
	    END;
        CLOSE tovs;
      end

/*      if @type_id = 14 --ретробонусы от поставщика/производителя
      begin
      	--
      end

      */
      	
      FETCH NEXT FROM cur_type into @type_id
    END;
    
    CLOSE cur_type

    DEALLOCATE cur_type
	DEALLOCATE prs;    
	DEALLOCATE tovs;    
  	DEALLOCATE cstore; 
  	DEALLOCATE torgt;     
  end try
  begin catch
--    print 'catch close cur_type'
--    CLOSE cur_type
--    DEALLOCATE cur_type
    
--    CLOSE prs;
--	DEALLOCATE prs;    
    
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
  end catch
END