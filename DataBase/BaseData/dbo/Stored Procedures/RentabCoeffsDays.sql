CREATE PROCEDURE dbo.RentabCoeffsDays @day0 datetime, @day1 datetime, @ncod int, @ngrp int, @calctip int, @recalc bit, @withul bit
AS
BEGIN
--  set transaction isolation level read uncommitted
  declare 
  @ym_from int, 
  @ym_to int,
  @mn int,
  @cnt int
  
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

--  select @cnt = count(*) from RentabCalcDays where ym_from = @ym_from and ym_to = @ym_to and ncod = @ncod and (ngrp = @ngrp or @ngrp = -1)
  
  if @recalc = 1
  begin
    delete from RentabCalcDays where ym_from = @ym_from and ym_to = @ym_to 
    and ncod in (select @ncod union 
				select ncod from RentabUrLicaDet 
				where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1)) 
    and (ngrp = @ngrp or @ngrp = -1)
    
    --create table #i(datepost datetime, ncom int, hitag int, datefin datetime)
    create table #i(datepost datetime, ncom int, hitag int, kold int)
    insert into #i(datepost, ncom, hitag)
    select distinct i.nd, i.ncom, i.hitag from inpdet i
    where i.nd >= @day0 and i.nd <= @day1
    --group by i.nd, i.ncom, i.hitag

    --create table #f(datepost datetime, datefin datetime, ncom int, hitag int)
    create table #f(datepost datetime, kold int, ncom int, hitag int)
    insert into #f
    select a.DatePost, count(distinct a.WorkDate), a.ncom, a.hitag
    from
    MorozArc..ArcVI a
    inner join nomen n on n.hitag = a.hitag
    inner join gr g on g.ngrp = n.ngrp
    inner join SkladList sl on sl.SkladNo = a.Sklad
    where a.WorkDate >= @day0 and a.WorkDate <= @day1
    and sl.Discard = 0
    and g.Ngrp not in (0, 84, 86, 90)    
--    and a.DatePost >= @day0
    group by a.DatePost, a.ncom, a.hitag

    update #i set kold = (select kold from #f where #i.datepost = #f.datepost and #i.hitag = #f.hitag and #i.ncom = #f.ncom)

    create table #rcd(ym_from int, ym_to int, obl_id int, days int, ncod int, ngrp int)
    
  --  insert into RentabCalcDays(ym_from, ym_to, obl_id, days, ncod, ngrp)	
    if @calctip = 1
    begin
      insert into #rcd(ym_from, ym_to, obl_id, days, ncod, ngrp)	
      select @ym_from, @ym_to, cast(o.Obl_ID as int) obl_id, avg(#i.kold), @ncod, g.mainparent from 
      obl o,
      #i
      inner join nomen n on n.hitag = #i.hitag
      inner join gr g on g.ngrp = n.ngrp
      inner join visual v on v.hitag = #i.hitag
      inner join skladlist sl on sl.SkladNo = v.sklad
      where
      (g.mainparent = @ngrp or @ngrp = -1)
      and v.ncod in (select @ncod union 
       				select ncod from RentabUrLicaDet 
					where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @ncod and @withul = 1))
--      and o.obl_id in (1, 5, 7, 8, 14)
      and sl.Discard = 0      
      and g.Ngrp not in (0, 84, 86, 90)      
      group by o.obl_id, g.mainparent
    end
    if @calctip = 2
    begin
      insert into #rcd(ym_from, ym_to, obl_id, days, ncod, ngrp)	
      select @ym_from, @ym_to, cast(o.Obl_ID as int) obl_id, avg(#i.kold), @ncod, g.mainparent from 
      obl o,
      #i
      inner join nomen n on n.hitag = #i.hitag
      inner join gr g on g.ngrp = n.ngrp
      inner join visual v on v.hitag = #i.hitag
      inner join skladlist sl on sl.SkladNo = v.sklad      
      where
      (g.mainparent = @ngrp or @ngrp = -1)
--      and o.obl_id in (1, 5, 7, 8, 14)
      and sl.Discard = 0
      and g.Ngrp not in (0, 84, 86, 90)
      group by o.obl_id, g.mainparent
    end  
    
    insert into RentabCalcDays select * from #rcd
    
    drop table #i
    drop table #f  
    drop table #rcd 
  end
  
  end try
  begin catch
    --    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    insert into ProcErrors(errnum, errmess, procname) select ERROR_NUMBER(), ERROR_MESSAGE(), object_name(@@procid)
  end catch     
END