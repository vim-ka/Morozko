CREATE PROCEDURE dbo.RentabCoeffsRetroB @day0 datetime, @day1 datetime, @ncod int, @ngrp int, @calctip int, @isnet bit, @recalc bit,
@withul bit
AS
BEGIN
--  set transaction isolation level read uncommitted
  declare 
  @ym_from int, 
  @ym_to int,
  @mn int
  
  begin try
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
--  print @ym_from
--  print @ym_to  
--  print @ncod
--  print @ngrp
  if @recalc = 1
  begin
    delete from RentabCalcRetroB where ym_from = @ym_from and ym_to = @ym_to 
    and ncod in (select @ncod union 
				select ncod from RentabUrLicaDet 
				where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
    and (ngrp = @ngrp or @ngrp = -1) 
    
    create table #rb(ym_from int, ym_to int, obl_id int, plata numeric(10, 2), ncod int, ngrp int, hitag int)
  --  insert into RentabCalcRetroB(ym_from, ym_to, obl_id, plata, ncod, ngrp)
    if @calctip = 1
    begin	
      insert into #rb(ym_from, ym_to, obl_id, plata, ncod, ngrp, hitag)
      /*select @ym_from, @ym_to, o.Obl_ID, round(sum(isnull(rrd.Bonus, 0)), 2), @ncod, g.MainParent, n.hitag
      from RetroB.Rb_RAW rbr
      inner join RetroB.rb_RawDet rrd on rrd.rawID = rbr.rawID
      INNER JOIN Retrob.rb_Buyers rb ON rb.RbId = rrd.rbID
      inner join dbo.Visual v on v.id = rbr.tekid
      inner join dbo.nomen n on n.hitag = v.hitag
      inner join dbo.gr g on g.Ngrp = n.ngrp
      inner join dbo.def d on d.pin = rbr.b_id
      inner join dbo.Obl o on o.Obl_ID = d.Obl_ID
--      inner join dbo.SkladList sl on sl.SkladNo = nv.sklad*/
	  select
        @ym_from, @ym_to, o.Obl_ID, round(sum(rd.Bonus), 2), @ncod, g.MainParent, n.hitag
      from 
        retrob.rb_Raw r
        inner join retrob.rb_Rawdet rd on rd.rawid=r.rawid
        INNER JOIN Retrob.rb_Buyers rb ON rb.RbId = rd.rbID  
      --  inner join retrob.rb_main m on m.rbid=d.rbid
        inner join dbo.Visual v on v.id = r.tekid
        inner join dbo.nomen n on n.hitag = v.hitag
        inner join dbo.gr g on g.Ngrp = n.ngrp
        inner join dbo.def d on d.pin = r.b_id
        inner join dbo.Obl o on o.Obl_ID = d.Obl_ID
      where r.vedID in (select rbv.vedid from RetroB.rb_Vedom rbv where rbv.day0 >= @day0 and rbv.day1 <= @day1)
      and r.ncod in (select @ncod union 
        			   select ncod from RentabUrLicaDet 
					   where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
      AND rb.Pin = r.b_id
      and (g.MainParent = @ngrp or @ngrp = -1)
--      and o.obl_id in (1, 5, 7, 8, 14)
      and g.Ngrp not in (0, 84, 86, 90)      
--      and sl.Discard = 0
      group by o.obl_id, g.MainParent, n.hitag
      --having sum(isnull(rrd.Bonus, 0)) > 0
    end
    if @calctip = 2 and @isnet = 0
    begin	
      insert into #rb(ym_from, ym_to, obl_id, plata, ncod, ngrp, hitag)
      /*select @ym_from, @ym_to, o.Obl_ID, round(sum(isnull(rrd.Bonus, 0)), 2), @ncod, g.MainParent, n.hitag
      from RetroB.Rb_RAW rbr
      inner join RetroB.rb_RawDet rrd on rrd.rawID = rbr.rawID
      INNER JOIN Retrob.rb_Buyers rb ON rb.RbId = rrd.rbID
      inner join dbo.Visual v on v.id = rbr.tekid
      inner join dbo.nomen n on n.hitag = v.hitag
      inner join dbo.gr g on g.Ngrp = n.ngrp
      inner join dbo.def d on d.pin = rbr.b_id
      inner join dbo.Obl o on o.Obl_ID = d.Obl_ID
--      inner join dbo.SkladList sl on sl.SkladNo = nv.sklad*/
      select
        @ym_from, @ym_to, o.Obl_ID, round(sum(rd.Bonus), 2), @ncod, g.MainParent, n.hitag
      from 
        retrob.rb_Raw r
        inner join retrob.rb_Rawdet rd on rd.rawid=r.rawid
        INNER JOIN Retrob.rb_Buyers rb ON rb.RbId = rd.rbID  
      --  inner join retrob.rb_main m on m.rbid=d.rbid
        inner join dbo.Visual v on v.id = r.tekid
        inner join dbo.nomen n on n.hitag = v.hitag
        inner join dbo.gr g on g.Ngrp = n.ngrp
        inner join dbo.def d on d.pin = r.b_id
        inner join dbo.Obl o on o.Obl_ID = d.Obl_ID
      where r.vedID in (select rbv.vedid from RetroB.rb_Vedom rbv where rbv.day0 >= @day0 and rbv.day1 <= @day1)
/*      and r.b_id in (select @ncod union 
        			   select ncod from RentabUrLicaDet 
					   where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
      AND rb.Pin = r.b_id*/
	  and rb.Pin in (select @ncod union 
        			   select ncod from RentabUrLicaDet 
					   where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
      and (g.MainParent = @ngrp or @ngrp = -1)
--      and o.obl_id in (1, 5, 7, 8, 14)
      and g.Ngrp not in (0, 84, 86, 90)      
--      and sl.Discard = 0
      group by o.obl_id, g.MainParent, n.hitag
     -- having sum(isnull(rrd.Bonus, 0)) > 0
    end  
  
    if @calctip = 2 and @isnet = 1
    begin	
      insert into #rb(ym_from, ym_to, obl_id, plata, ncod, ngrp, hitag)
/*      select @ym_from, @ym_to, o.Obl_ID, round(sum(isnull(rrd.Bonus, 0)), 2), @ncod, g.MainParent, n.hitag
      from RetroB.Rb_RAW rbr
      inner join RetroB.rb_RawDet rrd on rrd.rawID = rbr.rawID
      INNER JOIN Retrob.rb_Buyers rb ON rb.RbId = rrd.rbID
      inner join dbo.Visual v on v.id = rbr.tekid
      inner join dbo.nomen n on n.hitag = v.hitag
      inner join dbo.gr g on g.Ngrp = n.ngrp
      inner join dbo.def d on d.pin = rbr.b_id
      inner join dbo.Obl o on o.Obl_ID = d.Obl_ID
--      inner join dbo.SkladList sl on sl.SkladNo = nv.sklad
      where rbr.vedID in (select rbv.vedid from RetroB.rb_Vedom rbv where rbv.day0 >= @day0 and rbv.day1 <= @day1)
      and rbr.b_id in (select pin from dbo.def where master in 
				      (select @ncod union 
        		       select ncod from RentabUrLicaDet 
					   where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
      AND rb.Pin = @ncod
      )
      and (g.MainParent = @ngrp or @ngrp = -1)
--      and o.obl_id in (1, 5, 7, 8, 14)
      and g.Ngrp not in (0, 84, 86, 90)      
--      and sl.Discard = 0
      group by o.obl_id, g.MainParent, n.hitag
     -- having sum(isnull(rrd.Bonus, 0)) > 0*/
      select
        @ym_from, @ym_to, o.Obl_ID, round(sum(rd.Bonus), 2), @ncod, g.MainParent, n.hitag
      from 
        retrob.rb_Raw r
        inner join retrob.rb_Rawdet rd on rd.rawid=r.rawid
        INNER JOIN Retrob.rb_Buyers rb ON rb.RbId = rd.rbID  
      --  inner join retrob.rb_main m on m.rbid=d.rbid
        inner join dbo.Visual v on v.id = r.tekid
        inner join dbo.nomen n on n.hitag = v.hitag
        inner join dbo.gr g on g.Ngrp = n.ngrp
        inner join dbo.def d on d.pin = r.b_id
        inner join dbo.Obl o on o.Obl_ID = d.Obl_ID
      where
        r.vedID in (select rbv.vedid from RetroB.rb_Vedom rbv where rbv.day0 >= @day0 and rbv.day1 <= @day1)
/*        and r.b_id in (select pin from dbo.def where master in 
                      (select @ncod union 
                       select ncod from RentabUrLicaDet 
                       where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1)))
		AND rb.Pin = r.b_id*/
	    and rb.Pin in (select @ncod union 
        			   select ncod from RentabUrLicaDet 
					   where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
        
		and (g.MainParent = @ngrp or @ngrp = -1)
	    and g.Ngrp not in (0, 84, 86, 90)                               
      group by o.obl_id, g.MainParent, n.hitag     
     
    end    
    insert into RentabCalcRetroB select * from #rb
    
	drop table #rb
  end
  
  end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname, errline) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid), ERROR_LINE()
  end catch   
END