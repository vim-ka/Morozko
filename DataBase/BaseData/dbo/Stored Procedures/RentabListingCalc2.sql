CREATE PROCEDURE dbo.RentabListingCalc2 @day0 datetime, @day1 datetime, @pin int, @calctip int, @vend int, @onlypin int, @fg int = -1,
@depid INT = -1, @ag_id INT = -1
AS
BEGIN
declare
@ddf int,
@s_postvol2_kol numeric(18, 3),
@master int,
@lmid int,
@tip int,
@datefrom datetime,
@dateto datetime,
@dn1 int,
@dn2 int

set @ddf = DATEDIFF(month, @day0, @day1) + 1;
--print @ddf

--select @s_postvol2_kol = sum(s_postvol2_kol) from dbo.rentabbase2 where date_from = '01.01.2017' and date_to = '14.05.2017' and pin = 435

--print @s_postvol2_kol

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

if object_id('tempdb..#oi') is not null drop table #oi
create table #oi(our_id int)
if @fg = -1
begin
  insert into #oi select our_id from dbo.FirmsConfig where actual = 1
end
else
  insert into #oi select our_id from dbo.FirmsConfig where actual = 1 and FirmGroup = @fg

select @master = master from dbo.def where pin = @pin

if object_id('tempdb..#pin') is not null drop table #pin
create table #pin(pin INT, ag_id int)

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

if object_id('tempdb..#vend') is not null drop table #vend
create table #vend(ncod int)
if @vend = -1
	insert into #vend select ncod from dbo.vendors
else
	insert into #vend select @vend;

--select * from #vend

/*if object_id('tempdb..#rid') is not null drop table #rid
--create table #rid(lmid int, pin int, opl numeric(18, 3), vzm numeric(18, 3))
create table #rid(lmid int, pin int, tip int, datefrom datetime, dateto datetime)
insert into #rid
select rlm.id, rlm.pin, rld.tip, rld.datefrom, rld.dateto --,
--(SELECT ISNULL(SUM(summa), 0) FROM dbo.RentabListingDetOpl WHERE lmid = rlm.id AND tip = 1) ropl,
--(SELECT ISNULL(SUM(summa), 0) FROM dbo.RentabListingDetOpl WHERE lmid = rlm.id AND tip = 2) rvozm 
from dbo.RentabListingMain rlm 
inner join dbo.RentabListingDet rld on rld.lmid = rlm.id
inner join #pin pn on pn.pin = rlm.pin 
where rlm.soglfindir = 1 
and convert(varchar, @day0, 4) between rlm.datefrom and rlm.dateto 
and convert(varchar, @day1, 4) between rlm.datefrom and rlm.dateto*/

-- по идее здесь выбираем листинги, которые вообще следует считать...
-- как говорит Виктор - так или иначе ;-)
if object_id('tempdb..#rid') is not null drop table #rid
create table #rid(lmid int, pin int, tip int, sku_cnt int)
insert into #rid
select distinct rlm.id, rlm.pin, rld.tip, 
case when rld.tip = 1 then (select count(code) from RentabListingDet r 
where --(r.datefrom between @day0 and @day1 or r.dateto between @day0 and @day1) 
(@day0 between r.datefrom and r.dateto or @day1 between r.datefrom and r.dateto) 
and r.lmid = rlm.id)
when rld.tip = 2 then 
(select count(hitag) from rentabbase2 rbb where rbb.pin = @pin 
and cast(@day0 as datetime) = rbb.date_from and cast(@day1 as datetime) = rbb.date_to
and rbb.ncod in (select distinct code from RentabListingDet r where r.lmid = rlm.id
--and (r.datefrom between @day0 and @day1 or r.dateto between @day0 and @day1)
and (@day0 between r.datefrom and r.dateto or @day1 between r.datefrom and r.dateto) 
)
)
when rld.tip = 3 then 
(select count(hitag) from rentabbase2 rbb where rbb.pin = @pin and 
cast(@day0 as datetime) = rbb.date_from and cast(@day1 as datetime) = rbb.date_to
and rbb.mainparent in (select distinct code from RentabListingDet r where r.lmid = rlm.id
--and (r.datefrom between @day0 and @day1 or r.dateto between @day0 and @day1)
and (@day0 between r.datefrom and r.dateto or @day1 between r.datefrom and r.dateto) 
)
) end sku_cnt
from dbo.RentabListingMain rlm 
inner join dbo.RentabListingDet rld on rld.lmid = rlm.id
inner join (SELECT pin FROM #pin GROUP BY pin) pn on pn.pin = rlm.pin
inner join dbo.defcontract dc on dc.pin = rlm.pin
inner join #oi on #oi.our_id = dc.Our_id
--inner join #ags on #ags.ag_id = dc.ag_id
where rlm.soglfindir = 1 
--and (rlm.datefrom between @day0 and @day1
--or rlm.dateto between @day0 and @day1)
and (@day0 between rlm.datefrom and rlm.dateto 
or @day1 between rlm.datefrom and rlm.dateto)
group by rlm.id, rlm.pin, rld.tip

--select * from #rid
print 'посчитали rid'

delete from dbo.RentabListingTovs where lmid in (select lmid from #rid)
 
declare CC cursor FAST_FORWARD FOR select lmid, tip from #rid

open CC;
FETCH NEXT from CC INTO @lmid, @tip;
WHILE (@@FETCH_STATUS=0) 
BEGIN
--  print @lmid
--  print @tip
  if @tip = 1
  begin
	insert into dbo.RentabListingTovs select distinct @lmid, rbb.hitag, cast(@day0 as date), cast(@day1 as date), @tip, rbb.ncod from dbo.rentabbase2 rbb
  	inner join dbo.RentabListingDet rld on rld.code = rbb.hitag 
    inner join #vend vnd on vnd.ncod = rbb.ncod
	where cast(@day0 as date) = rbb.date_from and cast(@day1 as date) = rbb.date_to
    and rld.lmid = @lmid
	--and (rld.datefrom between @day0 and @day1 or rld.dateto between @day0 and @day1)
    and (@day0 between rld.datefrom and rld.dateto or @day1 between rld.datefrom and rld.dateto)
  end  
  if @tip = 2
  begin
	insert into dbo.RentabListingTovs select distinct @lmid, rbb.hitag, cast(@day0 as date), cast(@day1 as date), @tip, rbb.ncod from dbo.rentabbase2 rbb
	inner join #vend vnd on vnd.ncod = rbb.ncod
	where cast(@day0 as date) = rbb.date_from and cast(@day1 as date) = rbb.date_to
	and rbb.ncod in (select distinct code from dbo.RentabListingDet r where r.lmid = @lmid
--	and (r.datefrom between @day0 and @day1 or r.dateto between @day0 and @day1)
    and (@day0 between r.datefrom and r.dateto or @day1 between r.datefrom and r.dateto)
    )
  end
  if @tip = 3
  begin
	insert into dbo.RentabListingTovs select distinct @lmid, rbb.hitag, cast(@day0 as date), cast(@day1 as date), @tip, rbb.ncod from dbo.rentabbase2 rbb
	inner join #vend vnd on vnd.ncod = rbb.ncod
	where cast(@day0 as datetime) = rbb.date_from and cast(@day1 as datetime) = rbb.date_to
	and rbb.mainparent in (select distinct code from dbo.RentabListingDet r where r.lmid = @lmid
--	and (r.datefrom between @day0 and @day1 or r.dateto between @day0 and @day1)
    and (@day0 between r.datefrom and r.dateto or @day1 between r.datefrom and r.dateto)
    )  
  end
  fetch next from CC INTO @lmid, @tip;
END
close CC;
deallocate CC;

if object_id('tempdb..#rld') is not null drop table #rld
--create table #rld(lmid int, pin int, code int, datefrom datetime, dateto datetime, cnt int)
create table #rld(lmid int, pin int, code int, datefrom datetime, dateto datetime, cnt int, ncod int)
insert into #rld
select 
#rid.lmid, 
#rid.pin, 
rlt.hitag,
rlt.datefrom,
rlt.dateto,
--cc.cnt
#rid.sku_cnt,
rlt.ncod
from #rid
--inner join dbo.RentabListingDet rld on rld.lmid = #rid.lmid
--inner join (select lmid, count(*) cnt from dbo.RentabListingDet 
--where @day0 between datefrom and dateto and @day1 between datefrom and dateto group by lmid) cc on cc.lmid = rld.lmid
inner join dbo.RentabListingTovs rlt on rlt.lmid = #rid.lmid
--inner join (select lmid, count(*) cnt from dbo.RentabListingTovs 
--where @day0 between datefrom and dateto and @day1 between datefrom and dateto group by lmid) cc on cc.lmid = rlt.lmid
--where
--convert(varchar, @day0, 4) between rlt.datefrom and rlt.dateto
--and convert(varchar, @day1, 4) between rlt.datefrom and rlt.dateto
where #rid.sku_cnt > 0

--select * from #rld
print 'посчитали rld'

if object_id('tempdb..#opl') is not null drop table #opl
create table #opl(lmid int, summa numeric(18, 2), datefrom datetime, dateto DATETIME, icnt int)
insert into #opl
select
rldo.lmid,
isnull(sum(summa * rlov.coeff), 0) smm,
rldo.datefrom,
rldo.dateto,
DATEDIFF(DAY, IIF(rldo.datefrom >= @day0, rldo.datefrom, @day0), IIF(rldo.dateto <= @day1, rldo.dateto, @day1)) + 1
from
dbo.RentabListingDetOpl rldo
inner join #rid on #rid.lmid = rldo.lmid
inner join dbo.RentabListingOplataVid rlov on rlov.id = rldo.vid
--where convert(varchar, @day0, 4) between rldo.datefrom and rldo.dateto
--and convert(varchar, @day1, 4) between rldo.datefrom and rldo.dateto
where --(rldo.datefrom between @day0 and @day1 or rldo.dateto between @day0 and @day1)
(@day0 between rldo.datefrom and rldo.dateto or @day1 between rldo.datefrom and rldo.dateto)
and rldo.tip = 1
group by rldo.lmid, rldo.datefrom, rldo.dateto

--select * from #opl

print 'посчитали opl'

if object_id('tempdb..#vzm') is not null drop table #vzm
create table #vzm(lmid int, summa numeric(18, 2), datefrom datetime, dateto DATETIME, icnt int)
insert into #vzm
select
rldo.lmid,
isnull(sum(summa * rlov.coeff), 0) smm,
rldo.datefrom,
rldo.dateto,
DATEDIFF(DAY, IIF(rldo.datefrom >= @day0, rldo.datefrom, @day0), IIF(rldo.dateto <= @day1, rldo.dateto, @day1)) + 1
from
dbo.RentabListingDetOpl rldo
inner join #rid on #rid.lmid = rldo.lmid
inner join dbo.RentabListingOplataVid rlov on rlov.id = rldo.vid
--where convert(varchar, @day0, 4) between rldo.datefrom and rldo.dateto
--and convert(varchar, @day1, 4) between rldo.datefrom and rldo.dateto
where --(rldo.datefrom between @day0 and @day1 or rldo.dateto between @day0 and @day1)
(@day0 between rldo.datefrom and rldo.dateto or @day1 between rldo.datefrom and rldo.dateto)
and rldo.tip = 2
group by rldo.lmid, rldo.datefrom, rldo.dateto

--select * from #vzm

print 'посчитали vzm'

--truncate table dbo.rentablisting2
delete from dbo.rentablisting2 where 
exists(select * from dbo.rentablisting2 where date_from = cast(@day0 as date) and date_to = cast(@day1 as date) and calctip = @calctip and pin = @pin)

insert into dbo.rentablisting2
select
s.datefrom,
s.dateto,
s.calctip,
s.pin,
s.mainparent,
s.obl_id,
round(isnull(sum(s.opl_code), 0), 2),
round(isnull(sum(s.vzm_code), 0), 2),
s.code,
s.ncod,
s.lmid
from
(

select cast(@day0 as date) datefrom, cast(@day1 as date) dateto, @calctip calctip, @pin pin, g.mainparent mainparent, -1 obl_id, 
--isnull(#opl.summa * (DATEDIFF(month, #opl.datefrom, #opl.dateto) + 1) / @ddf / r.cnt, 0) opl_code,
--isnull(#vzm.summa * (DATEDIFF(month, #vzm.datefrom, #vzm.dateto) + 1) / @ddf / r.cnt, 0) vzm_code,
----isnull(#opl.summa / (DATEDIFF(day, #opl.datefrom, #opl.dateto) + 1) / r.cnt, 0) * (DATEDIFF(day, @day0, @day1) + 1) opl_code,
----isnull(#vzm.summa / (DATEDIFF(day, #vzm.datefrom, #vzm.dateto) + 1) / r.cnt, 0) * (DATEDIFF(day, @day0, @day1) + 1) vzm_code,
#opl.summa * #opl.icnt / (DATEDIFF(day, @day0, @day1) + 1) / r.cnt opl_code,
#vzm.summa * #vzm.icnt / (DATEDIFF(day, @day0, @day1) + 1) / r.cnt vzm_code,
r.code, --r.cnt,
--@vend ncod -- -1 ncod--, isnull(rbb2.ncod, -1) ncod

--(select top 1 #vend.ncod from dbo.nomenvend nvd
--inner join #vend on #vend.ncod = nvd.Ncod and r.code = nvd.Hitag
--where nvd.nd = (select max(nd) from dbo.nomenvend where ncod = #vend.ncod) ) ncod, 
r.ncod,

0 lmid --r.lmid
--iif(DATEDIFF(month, r.datefrom, r.dateto) = 0, 1, DATEDIFF(month, r.datefrom, r.dateto)) + 1,
--iif(DATEDIFF(month, #opl.datefrom, #opl.dateto) = 0, 1, DATEDIFF(month, #opl.datefrom, #opl.dateto)) + 1,
--iif(DATEDIFF(month, #vzm.datefrom, #vzm.dateto) = 0, 1, DATEDIFF(month, #vzm.datefrom, #vzm.dateto)) + 1
from
#rld r
left join #opl on #opl.lmid = r.lmid
left join #vzm on #vzm.lmid = r.lmid
inner join dbo.nomen n on n.hitag = r.code
inner join dbo.gr g on g.ngrp = n.ngrp
--left join dbo.rentabbase2 rbb2 on rbb2.hitag = r.code and rbb2.pin in (select pin from #pin) and rbb2.date_from = @day0 and rbb2.date_to = @day1

--where g.mainparent  = 3


--group by g.mainparent, r.code, r.lmid
) s
group by s.datefrom, s.dateto, s.calctip, s.pin, s.mainparent, s.obl_id, s.code, s.ncod, s.lmid












--это старый мусор, удалить после февраля
/*insert into dbo.rentablisting2
select @day0, convert(varchar, @day1, 4), @calctip, @pin, 
g.mainparent, -1, 
round(sum(isnull(#opl.summa, 0) * @ddf / r.cnt) / sum(DATEDIFF(month, #opl.datefrom, #opl.dateto) + 1), 2) opl_code, 
round(sum(isnull(#vzm.summa, 0) * @ddf / r.cnt) / sum(DATEDIFF(month, #vzm.datefrom, #vzm.dateto) + 1), 2) vzm_code, 
r.code,
-1 ncod--, --isnull(rbb2.ncod, -1) ncod
--iif(DATEDIFF(month, r.datefrom, r.dateto) = 0, 1, DATEDIFF(month, r.datefrom, r.dateto)) + 1,
--iif(DATEDIFF(month, #opl.datefrom, #opl.dateto) = 0, 1, DATEDIFF(month, #opl.datefrom, #opl.dateto)) + 1,
--iif(DATEDIFF(month, #vzm.datefrom, #vzm.dateto) = 0, 1, DATEDIFF(month, #vzm.datefrom, #vzm.dateto)) + 1
from
#rld r
left join #opl on #opl.lmid = r.lmid
left join #vzm on #vzm.lmid = r.lmid
inner join dbo.nomen n on n.hitag = r.code
inner join dbo.gr g on g.ngrp = n.ngrp
--left join dbo.rentabbase2 rbb2 on rbb2.hitag = r.code and rbb2.pin in (select pin from #pin) --and rbb2.date_from = @day0 and rbb2.date_to = @day1
group by g.mainparent, r.code
--order by r.lmid*/


END