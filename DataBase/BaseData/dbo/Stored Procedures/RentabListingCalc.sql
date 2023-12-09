CREATE PROCEDURE dbo.RentabListingCalc @day0 datetime, @day1 datetime, @ncod int, @ngrp int, @with_actn bit, 
@calctip int, @isnet bit, @recalc bit, @withul bit
AS
BEGIN
  declare 
  @ym_from int, 
  @ym_to int,
  @mn int,
  @tip int,
  @lmid int,
  @code int, --код товара, поставщика, категории
  @lso numeric(10, 3),
  @lsv numeric(10, 3),
  @psv numeric(10, 3),
  @daystart datetime,
  @dayfinish datetime,
  @day0c datetime,
  @day1c datetime
  
  set @mn = datepart(month, @day0)
  if @mn < 10
    set @ym_from = convert(int, convert(varchar(4), datepart(year, @day0)) + '0' + convert(varchar(2), @mn))
  else
    set @ym_from = convert(int, convert(varchar(4), datepart(year, @day0)) + convert(varchar(2), @mn))  
  set @mn = datepart(month, @day1)    
  if @mn < 10
    set @ym_to = convert(int, convert(varchar(4), datepart(year, @day1)) + '0' + convert(varchar(2), @mn))  
  else
    set @ym_to = convert(int, convert(varchar(4), datepart(year, @day1)) + convert(varchar(2), @mn))
  
--  create table #li(ym_from int, ym_to int, calctip int, ncod int, ngrp int, obl_id int, 
--  	l_sum_opl numeric(12, 2), l_sum_vozm numeric(12, 2), listtipoper int, hitag int, postvol numeric(10 ,3))
  create table #t2(ym_from int, ym_to int, calctip int, ncod int, ngrp int, obl_id int, l_sum_opl numeric(10, 3), l_sum_vozm numeric(10, 3), 
    listtipoper int, hitag int, postvol numeric(10, 3), sum_postvol numeric(10, 3))

  if @isnet = 0
  begin
/*    insert into #li(ym_from, ym_to, calctip, ncod, ngrp, obl_id, l_sum_opl, l_sum_vozm, listtipoper, hitag, postvol)
    select @ym_from, @ym_to, @calctip, @ncod, g.MainParent, d.Obl_ID,
    isnull(sum(sum_opl), 0) / count(rlt.hitag), isnull(sum(sum_vozm), 0) / count(rlt.hitag), rld.tip, rlt.hitag
    from --dbo.obl o,
    dbo.RentabListingMain rlm
    left join dbo.RentabListingDet rld on rld.lmid = rlm.id
--    inner join dbo.RentabListingDetOpl rldo on rldo.lmid = rlm.id    
    inner join dbo.RentabListingTovs rlt on rlt.lmid = rlm.id        
    inner join dbo.nomen n on n.hitag = rlt.hitag
    inner join dbo.gr g on g.Ngrp = n.ngrp
    inner join dbo.def d on d.pin = rlm.pin
    where
	(rlm.datefrom between @day0 and @day1 
    or rlm.dateto between @day0 and @day1)
    and rlm.pin in (select @ncod union 
					select ncod from RentabUrLicaDet 
					where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1)
                    )
    and (g.MainParent = @ngrp or @ngrp = -1)  
    group by d.Obl_ID, g.mainparent, rld.tip, rlt.hitag
    having count(rlt.hitag) > 0*/
    select @lso = sum_opl from dbo.RentabListingMain rlm where (rlm.datefrom between @day0 and @day1 or rlm.dateto between @day0 and @day1) and pin = @ncod
    select @lsv = sum_vozm from dbo.RentabListingMain rlm where (rlm.datefrom between @day0 and @day1 or rlm.dateto between @day0 and @day1) and pin = @ncod

    insert into #t2
    select distinct @ym_from, @ym_to, @calctip, @ncod, rc.ngrp, d.obl_id, null, null, rld.tip, rlt.hitag, rc.postvol, null
    from
    dbo.RentabListingMain rlm
    inner join dbo.RentabListingDet rld on rld.lmid = rlm.id
    inner join dbo.RentabListingTovs rlt on rlt.lmid = rlm.id  
    inner join
    (select postvol, hitag, ym_from, ym_to, ngrp, ncod from dbo.rentabcalc) 
    rc on rc.hitag = rlt.hitag and rc.ym_from = @ym_from and rc.ym_to = @ym_to and rc.ncod = rlm.pin
    --group by rld.tip, rlt.hitag
    inner join dbo.nomen n on n.hitag = rlt.hitag
    inner join dbo.gr g on g.Ngrp = n.ngrp
    inner join dbo.def d on d.pin = rlm.pin
    where
	(rlm.datefrom between @day0 and @day1 
    or rlm.dateto between @day0 and @day1) 
    and rlm.pin in (select @ncod union 
					select ncod from RentabUrLicaDet 
					where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1)
                    )
    and (g.MainParent = @ngrp or @ngrp = -1)    

    select @psv = sum(#t2.postvol) from #t2
    print @psv
    print @lso

    update #t2 set #t2.sum_postvol = @psv, #t2.l_sum_opl = @lso * #t2.postvol / @psv, #t2.l_sum_vozm = @lsv * #t2.postvol / @psv  
    where #t2.ym_from = @ym_from and #t2.ym_to = @ym_to and #t2.ncod = @ncod
  end
  if @isnet = 1
  begin
--    insert into #li(ym_from, ym_to, calctip, ncod, ngrp, obl_id, l_sum_opl, l_sum_vozm, listtipoper, hitag, postvol)
    /*select @ym_from, @ym_to, @calctip, @ncod, g.MainParent, d.Obl_ID,
    isnull(sum(sum_opl), 0) / count(rlt.hitag), isnull(sum(sum_vozm), 0) / count(rlt.hitag), rld.tip, rlt.hitag
    from --dbo.obl o,
    dbo.RentabListingMain rlm
    inner join dbo.RentabListingDet rld on rld.lmid = rlm.id
--    inner join dbo.RentabListingDetOpl rldo on rldo.lmid = rlm.id    
    inner join dbo.RentabListingTovs rlt on rlt.lmid = rlm.id        
    inner join dbo.nomen n on n.hitag = rlt.hitag
    inner join dbo.gr g on g.Ngrp = n.ngrp
    inner join dbo.def d on d.pin = rlm.pin
    where
	(rlm.datefrom between @day0 and @day1 
    or rlm.dateto between @day0 and @day1) 
    and rlm.pin in (select pin from dbo.def where master in (
      				select @ncod union 
					select ncod from RentabUrLicaDet 
					where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
                    )
    and (g.MainParent = @ngrp or @ngrp = -1)  
    group by d.Obl_ID, g.mainparent, rld.tip, rlt.hitag
    having count(rlt.hitag) > 0    */
    
    select @lso = sum_opl from dbo.RentabListingMain rlm where (rlm.datefrom between @day0 and @day1 or rlm.dateto between @day0 and @day1) and pin = @ncod
    select @lsv = sum_vozm from dbo.RentabListingMain rlm where (rlm.datefrom between @day0 and @day1 or rlm.dateto between @day0 and @day1) and pin = @ncod

    insert into #t2
    select distinct @ym_from, @ym_to, @calctip, @ncod, rc.ngrp, d.obl_id, null, null, rld.tip, rlt.hitag, rc.postvol, null
    from
    dbo.RentabListingMain rlm
    inner join dbo.RentabListingDet rld on rld.lmid = rlm.id
    inner join dbo.RentabListingTovs rlt on rlt.lmid = rlm.id  
    inner join
    (select postvol, hitag, ym_from, ym_to, ngrp, ncod from dbo.rentabcalc) 
    rc on rc.hitag = rlt.hitag and rc.ym_from = @ym_from and rc.ym_to = @ym_to and rc.ncod = rlm.pin
    --group by rld.tip, rlt.hitag
    inner join dbo.nomen n on n.hitag = rlt.hitag
    inner join dbo.gr g on g.Ngrp = n.ngrp
    inner join dbo.def d on d.pin = rlm.pin
    where
	(rlm.datefrom between @day0 and @day1 
    or rlm.dateto between @day0 and @day1) 
    and rlm.pin in (select pin from dbo.def where master in (
      				select @ncod union 
					select ncod from RentabUrLicaDet 
					where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
                    )
    and (g.MainParent = @ngrp or @ngrp = -1)    

    select @psv = sum(#t2.postvol) from #t2
    print @psv
    print @lso

    update #t2 set #t2.sum_postvol = @psv, #t2.l_sum_opl = @lso * #t2.postvol / @psv, #t2.l_sum_vozm = @lsv * #t2.postvol / @psv  
    where #t2.ym_from = @ym_from and #t2.ym_to = @ym_to and #t2.ncod = @ncod
    
--    insert into #li(ym_from, ym_to, calctip, ncod, ngrp, obl_id, l_sum_opl, l_sum_vozm, listtipoper, hitag, postvol) 
--    select #t2.ym_from, #t2.ym_to, #t2.calctip, #t2.ncod, #t2.ngrp, #t2.obl_id, #t2.l_sum_opl, #t2.l_sum_vozm, #t2.listtipoper, #t2.hitag, 
    
    --drop table #t2
  end
  delete from dbo.RentabCalcListing where ym_from = @ym_from and ym_to = @ym_to and ncod = @ncod and calctip = @calctip
  insert into dbo.RentabCalcListing
--  select * from #li
  select * from #t2
  drop table #t2  
  --drop table #li
END