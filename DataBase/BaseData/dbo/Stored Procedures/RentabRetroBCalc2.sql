CREATE PROCEDURE dbo.RentabRetroBCalc2 @day0 datetime, @day1 datetime, @pin int, @calctip int, @vend int, @onlypin bit, @depid int = -1, @ag_id int = -1
AS
BEGIN
declare
@master int

select @master = master from dbo.def where pin = @pin

if object_id('tempdb..#ags') is not null drop table #ags
create table #ags(ag_id int)
IF @depid = -1
  INSERT INTO #ags SELECT al.ag_id FROM dbo.AgentList al 
  --inner join dbo.person p on p.p_id = al.p_id --and p.depid = al.depid
  WHERE al.AG_ID = @ag_id AND al.P_ID <> 0 --and p.closed = 0
else
begin
  IF @ag_id = -1
    INSERT INTO #ags SELECT al.ag_id FROM dbo.AgentList al 
    --inner join dbo.person p on p.p_id = al.p_id --and p.depid = al.depid
    WHERE al.depid = @depid AND al.P_ID <> 0 --and p.closed = 0
  else
    INSERT INTO #ags SELECT al.ag_id FROM dbo.AgentList al 
    --inner join dbo.person p on p.p_id = al.p_id --and p.depid = al.depid
    WHERE al.depid = @depid AND al.AG_ID = @ag_id AND al.P_ID <> 0 --and p.closed = 0
end
IF @depid = -1 AND @ag_id = -1
  INSERT INTO #ags SELECT ag_id FROM dbo.AgentList al WHERE al.P_ID <> 0

--SELECT * FROM #ags ORDER BY ag_id

if object_id('tempdb..#pin') is not null drop table #pin
create table #pin(pin int, ag_id int)

if object_id('tempdb..#ulpin') is not null drop table #ulpin
create table #ulpin(pin int)      
insert into #ulpin
select ncod from RentabUrLicaDet where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @pin)

if @pin <> -1 
begin
  if @onlypin = 0
      insert into #pin 
      select distinct def.pin, dc.ag_id from dbo.def 
      inner join dbo.defcontract dc on dc.pin = def.pin
      INNER JOIN #ags ON #ags.ag_id = dc.ag_id
      where 
      dc.ContrTip not in (5, 7)
      and ((def.master in (select pin from #ulpin) or (def.master = @master and @master <> 0)) or def.pin in (select pin from #ulpin)) or def.pin = @pin
      and def.Worker = 0
  else
      insert into #pin select pin, dc.ag_id from dbo.defcontract dc 
      INNER JOIN #ags ON #ags.ag_id = dc.ag_id
      where dc.pin = @pin;
end
else
  insert into #pin 
  select distinct def.pin, dc.ag_id from dbo.def 
  inner join dbo.defcontract dc on dc.pin = def.pin
  INNER JOIN #ags ON #ags.ag_id = dc.ag_id
  where 
  dc.ContrTip not in (5, 7)
  and def.Worker = 0

--select * from #pin

if object_id('tempdb..#vend') is not null drop table #vend
create table #vend(ncod int)
if @vend = -1
	insert into #vend select ncod from dbo.vendors
else
	insert into #vend select @vend;

--select * from #vend

--truncate table dbo.rentabretrob2 
delete from dbo.rentabretrob2 where 
exists(select * from dbo.rentabretrob2 where date_from = convert(varchar, @day0, 4) and date_to = convert(varchar, @day1, 4) and calctip = @calctip and pin = @pin)

if object_id('tempdb..#ved') is not null drop table #ved
create table #ved(vedid int)
insert into #ved
select rbv.vedid from RetroB.rb_Vedom rbv where rbv.day0 <= @day1 and rbv.day1 >= @day0

--select * from #ved

if object_id('tempdb..#rdata') is not null drop table #rdata
create table #rdata(hitag int, bn numeric(18, 3), ncod int, ngrp int, b_id int)
insert into #rdata
select r.hitag, rd.bonus, r.Ncod, r.ngrp, r.b_id
from 
  retrob.rb_Raw r
inner join #ved on #ved.vedid = r.vedID  
inner join retrob.rb_Rawdet rd on rd.rawid = r.rawid
--inner join Retrob.rb_Buyers rb ON rb.RbId = rd.rbID
--inner join retrob.rb_main m on m.rbid = rd.rbid
inner join (SELECT pin FROM #pin GROUP BY pin) pn on pn.pin = r.b_id
inner join #vend vnd on vnd.ncod = r.ncod
INNER JOIN #ags a ON a.ag_id = r.Ag_Id
--r.vedID in (select rbv.vedid from RetroB.rb_Vedom rbv where rbv.day0 >= '01.06.2017' and rbv.day1 <= '30.06.2017 23:59:59')
--and 
--where r.Hitag = 23201
--group by r.hitag, 
--rd.bonus, 
--r.Ncod, r.ngrp, r.b_id

--select * from #rdata

/*if object_id('tempdb..#bns') is not null drop table #bns
create table #bns(hitag int, bn numeric(12, 2), ncod int, ngrp int)
insert into #bns
select r.hitag, isnull(rd.bonus, 0), r.Ncod, r.Ngrp
from 
  retrob.rb_Raw r
left join retrob.rb_Rawdet rd on rd.rawid = r.rawid
left join Retrob.rb_Buyers rb ON rb.RbId = rd.rbID
inner join #ved on #ved.vedid = r.vedID  
left join #pin pn on pn.pin = r.b_id
left join #vend vnd on vnd.ncod = r.ncod
--where 
--r.vedID in (select rbv.vedid from RetroB.rb_Vedom rbv where rbv.day0 >= '01.06.2017' and rbv.day1 <= '30.06.2017 23:59:59')
--and 
--r.Hitag = 23201
group by r.hitag, rd.bonus, r.Ncod, r.ngrp

select * from #bns

insert into dbo.rentabretrob2
select 
  @day0, 
  convert(varchar, @day1, 104), 
  @calctip,
  @pin, 
  g.MainParent, 
  0 obl_id, --o.Obl_ID, 
  round(sum(isnull(#bns.bn, 0)), 2) sum_bonus,
  r.hitag,
  r.ncod
from 
  retrob.rb_Raw r
--  left join #ved on #ved.vedid = r.vedID
  inner join #bns on #bns.hitag = r.Hitag
--  left join retrob.rb_Rawdet rd on rd.rawid = r.rawid
--  left JOIN Retrob.rb_Buyers rb ON rb.RbId = rd.rbID
--  left join retrob.rb_main m on m.rbid = rd.rbid
--  left join dbo.Visual v on v.id = r.tekid
--  left join dbo.nomen n on n.hitag = v.hitag
  left join dbo.gr g on g.Ngrp = r.Ngrp
--  inner join dbo.def d on d.pin = r.b_id
--  inner join dbo.Obl o on o.Obl_ID = d.Obl_ID
  inner join #vend vnd on vnd.ncod = r.ncod
  inner join #pin pn on pn.pin = r.b_id
--where r.vedID in (select rbv.vedid from RetroB.rb_Vedom rbv where rbv.day0 >= @day0 and rbv.day1 <= @day1)
--where r.Hitag = 23201
group by g.MainParent, r.hitag, r.ncod --,o.obl_id,
*/
insert into dbo.rentabretrob2
select 
  @day0, 
  convert(varchar, @day1, 4), 
  @calctip,
  @pin, 
  g.MainParent, 
  0 obl_id, --o.Obl_ID, 
  round(rdt.bn, 2) sum_bonus,
--  round(rdt.bn, 2) sum_bonus,
  rdt.hitag,
  rdt.ncod
from 
  #rdata rdt
  inner join dbo.GR g on g.ngrp = rdt.ngrp
--group by g.MainParent, rdt.hitag, rdt.ncod--, rdt.bn --,o.obl_id,*/

END