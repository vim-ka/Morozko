CREATE PROCEDURE dbo.MarketRequestProdTovUp @mrid int
AS
BEGIN
declare
@hitag int,
@dn1 int,
@dn2 int,
@dn1_prev int,
@dn2_prev int,
@dn1_prev_year int,
@dn2_prev_year int,
@nd1 datetime,
@nd2 datetime,
@pin int,
@isnet bit

select @pin = pin, @isnet = isnet, @nd1 = datefrom, @nd2 = dateto from dbo.MarketRequest where id = @mrid
--select pin, isnet, datefrom, dateto from dbo.MarketRequest where id = @mrid

create table #t(b_id int)
if @pin = -1
insert into #t select def.pin from dbo.def 
inner join dbo.defcontract dc on dc.pin = def.pin 
inner join dbo.AgentList al on al.AG_ID = dc.ag_id
inner join dbo.MarketRequestDeps mrd on mrd.depid = al.DepID group by def.pin
else if @isnet = 1
insert into #t select def.pin from dbo.def 
inner join dbo.defcontract dc on dc.pin = def.pin 
inner join dbo.AgentList al on al.AG_ID = dc.ag_id
inner join dbo.MarketRequestDeps mrd on mrd.depid = al.DepID group by def.pin
else insert into #t values(@pin)
create index tempt on #t(b_id)
--select * from #t
--drop table #t

CREATE TABLE #wr(datefrom datetime, dateto datetime, sum_kol NUMERIC(18, 2), wgt NUMERIC(18, 2), 
--avg_cost NUMERIC(12, 2), avg_price NUMERIC(12, 2), proc_naz NUMERIC(12, 2), 
tip INT, depid int)

set @dn1 = dbo.InDatNom(0000, @nd1)
set @dn2 = dbo.InDatNom(9999, @nd2)
set @dn1_prev = dbo.InDatNom(0000, dateadd(month, -1, @nd1))
set @dn2_prev = dbo.InDatNom(9999, dateadd(month, -1, @nd2))
set @dn1_prev_year = dbo.InDatNom(0000, dateadd(year, -1, @nd1))
set @dn2_prev_year = dbo.InDatNom(9999, dateadd(year, -1, @nd2))

INSERT INTO #wr
select 
@nd1 datefrom, 
@nd2 dateto, 
isnull(sum(nv.kol), 0) sum_kol, 
round(isnull(sum(iif(v.weight = 0, n.Netto, v.weight) * isnull(nv.kol, 0)), 0), 2) wgt,
--round(isnull(avg(nv.Cost), 0), 2) avg_cost, 
--round(isnull(avg(nv.Price), 0), 2) avg_price, 
--round(isnull(100 * (sum(nv.kol * nv.price) / sum(nv.kol * nv.cost) - 1), 0), 2) proc_naz, 
1 tip, 
al.depid 
--into #res
from nv 
inner join visual v on v.id = nv.TekID
inner join nomen n on n.hitag = nv.hitag
inner join nc nc on nc.DatNom = nv.DatNom
inner join defcontract dc on dc.dck = nc.DCK
inner join AgentList al on al.AG_ID = dc.Ag_Id
inner JOIN #t ON #t.b_id = nc.b_id 
inner JOIN dbo.MarketRequestTovs mrt ON mrt.mrid = @mrid AND mrt.hitag = nv.hitag
where nv.datnom >= @dn1 and nv.datnom <= @dn2 
AND al.depid IN (select depid FROM dbo.MarketRequestDeps WHERE mrid = @mrid)
group by al.DepID
having sum(nv.kol * nv.cost) <> 0

IF NOT EXISTS(SELECT * FROM #wr WHERE tip = 1)
   INSERT INTO #wr SELECT @nd1, @nd2, 0, 0,
   --0, 0, 0, 
   1, mrd.depid FROM dbo.MarketRequestDeps mrd WHERE mrid = @mrid --(datefrom, dateto, sum_kol, wgt, avg_cost, avg_price, proc_naz, tip, depid) VALUES(@nd1, @nd2, 0, 0 ,0, 0, 0, 1, -1)

INSERT INTO #wr
select 
dateadd(month, -1, @nd1), 
dateadd(month, -1, @nd2),
isnull(sum(nv.kol), 0) sum_kol, 
round(isnull(sum(iif(v.weight = 0, n.Netto, v.weight) * isnull(nv.kol, 0)), 0), 2) wgt,
--round(isnull(avg(nv.Cost), 0), 2) avg_cost, 
--round(isnull(avg(nv.Price), 0), 2) avg_price, 
--round(isnull(100 * (sum(nv.kol * nv.price) / sum(nv.kol * nv.cost) - 1), 0), 2) proc_naz, 
2 tip, 
al.depid 
--into #res
from nv 
inner join visual v on v.id = nv.TekID
inner join nomen n on n.hitag = nv.hitag
inner join nc nc on nc.DatNom = nv.DatNom
inner join defcontract dc on dc.dck = nc.DCK
inner join AgentList al on al.AG_ID = dc.Ag_Id
inner JOIN #t ON #t.b_id = nc.b_id 
inner JOIN dbo.MarketRequestTovs mrt ON mrt.mrid = @mrid AND mrt.hitag = nv.hitag
where  nv.datnom >= @dn1_prev and nv.datnom <= @dn2_prev
AND al.depid IN (select depid FROM dbo.MarketRequestDeps WHERE mrid = @mrid)
group by al.DepID
having sum(nv.kol * nv.cost) <> 0

IF NOT EXISTS(SELECT * FROM #wr WHERE tip = 2)
   INSERT INTO #wr SELECT @nd1, @nd2, 0, 0,
   --0, 0, 0, 
   2, mrd.depid FROM dbo.MarketRequestDeps mrd WHERE mrid = @mrid

INSERT INTO #wr
select 
dateadd(year, -1, @nd1), 
dateadd(year, -1, @nd2),
isnull(sum(nv.kol), 0) sum_kol, 
round(isnull(sum(iif(v.weight = 0, n.Netto, v.weight) * isnull(nv.kol, 0)), 0), 2) wgt,
--round(isnull(avg(nv.Cost), 0), 2) avg_cost, 
--round(isnull(avg(nv.Price), 0), 2) avg_price, 
--round(isnull(100 * (sum(nv.kol * nv.price) / sum(nv.kol * nv.cost) - 1), 0), 2) proc_naz, 
3 tip, 
al.depid 
--into #res
from nv 
inner join visual v on v.id = nv.TekID
inner join nomen n on n.hitag = nv.hitag
inner join nc nc on nc.DatNom = nv.DatNom
inner join defcontract dc on dc.dck = nc.DCK
inner join AgentList al on al.AG_ID = dc.Ag_Id
inner JOIN #t ON #t.b_id = nc.b_id 
inner JOIN dbo.MarketRequestTovs mrt ON mrt.mrid = @mrid AND mrt.hitag = nv.hitag
where   nv.datnom >= @dn1_prev_year and nv.datnom <= @dn2_prev_year
AND al.depid IN (select depid FROM dbo.MarketRequestDeps WHERE mrid = @mrid)
group by al.DepID
having sum(nv.kol * nv.cost) <> 0

IF NOT EXISTS(SELECT * FROM #wr WHERE tip = 3)
   INSERT INTO #wr SELECT @nd1, @nd2, 0, 0,
--    0, 0, 0, 
   3, mrd.depid FROM dbo.MarketRequestDeps mrd WHERE mrid = @mrid

INSERT INTO #wr
select 
@nd2 + 1, 
dbo.today(), 
isnull(sum(nv.kol), 0) sum_kol, 
round(isnull(sum(iif(v.weight = 0, n.Netto, v.weight) * isnull(nv.kol, 0)), 0), 2) wgt,
--round(isnull(avg(nv.Cost), 0), 2) avg_cost, 
--round(isnull(avg(nv.Price), 0), 2) avg_price, 
--round(isnull(100 * (sum(nv.kol * nv.price) / sum(nv.kol * nv.cost) - 1), 0), 2) proc_naz, 
4 tip, 
al.depid 
from nv 
inner join visual v on v.id = nv.TekID
inner join nomen n on n.hitag = nv.hitag
inner join nc nc on nc.DatNom = nv.DatNom
inner join AgentList al on al.AG_ID = nc.Ag_Id
where nv.datnom > @dn2 and nv.datnom <= dbo.InDatNom(9999, dbo.today()) 
and nv.hitag in (select hitag from dbo.MarketRequestTovs where mrid = @mrid)
group by al.DepID
having sum(nv.kol * nv.cost) <> 0

IF NOT EXISTS(SELECT * FROM #wr WHERE tip = 4)
   INSERT INTO #wr SELECT @nd1, @nd2, 0, 0, 
--   0, 0, 0, 
   4, mrd.depid FROM dbo.MarketRequestDeps mrd WHERE mrid = @mrid

INSERT INTO #wr
select 
@nd1, 
@nd2, 
isnull(avg(mm.upplankol), 0) sum_kol, 
isnull(avg(mm.upplanweight), 0) wgt, 
--round(isnull(avg(nv.Cost), 0), 2) avg_cost, 
--round(isnull(sum(mrt.price) / count(mrt.price), 2), 0) avg_price, 
--round(isnull(100 * (avg(mrt.price) / avg(nv.Cost) - 1), 0), 2) proc_naz, 
5 tip, 
mm.depid 
from dbo.MarketRequestSogl mm
inner join dbo.MarketRequest mr on mr.id = mm.mrid
inner join dbo.MarketRequestTovs mrt on mrt.mrid = mm.mrid
inner join dbo.nv nv on nv.hitag = mrt.hitag
inner join nc nc on nc.DatNom = nv.DatNom
inner join AgentList al on al.AG_ID = nc.Ag_Id
inner JOIN #t ON #t.b_id = nc.b_id 
--INNER JOIN dbo.MarketRequestDeps mrd ON mrd.mrid = mm.mrid
where
nv.datnom >= @dn1_prev and nv.datnom <= @dn2_prev
AND mr.id = @mrid
AND mm.depid IN (select depid FROM dbo.MarketRequestDeps WHERE mrid = @mrid)
group by mm.DepID

IF NOT EXISTS(SELECT * FROM #wr WHERE tip = 5)
   INSERT INTO #wr SELECT @nd1, @nd2, 0, 0,
   --0, 0, 0, 
   5, mrd.depid FROM dbo.MarketRequestDeps mrd WHERE mrid = @mrid

SELECT 
s.*,
case when s.tip = 1 then 'показатели на период проведения акции'
when s.tip = 2 then 'показатели за предыдущий месяц'
when s.tip = 3 then 'показатели за предыдущий год'
when s.tip = 4 then 'показатели c момента завершения акции' 
when s.tip = 5 then 'плановые показатели' end tip_name,
d.dname,
mrs.sogl
FROM 
#wr s
left join deps d on d.depid = s.depid
left join dbo.MarketRequestSogl mrs on mrs.mrid = @mrid and mrs.depid = s.depid
where s.depid in (select depid from marketrequestdeps where mrid = @mrid)
order by s.depid, s.tip

/*if not exists(select 1 from #res)
	insert into #res(datefrom,dateto,sum_kol,wgt,avg_cost,avg_price,proc_naz,tip,depid) 
  values(@nd1, @nd2, 0, 0, 0, 0, 0, 1, 0)*/
  
--select * from #res

/*select
s.*,
--  ISNULL(s.datefrom, @nd1) datefrom, ISNULL(s.dateto, @nd2) dateto, ISNULL(s.sum_kol, 0) sum_kol, ISNULL(s.wgt, 0) wgt, ISNULL(s.avg_cost, 0) avg_cost, ISNULL(s.avg_price, 0) avg_price, ISNULL(s.proc_naz, 0) proc_naz, ISNULL(s.tip, -1) tip, ISNULL(s.DepID, -1) depid,
case WHEN ISNULL(s.tip, -1) = 1 then '?????????? ?? ?????? ?????????? ?????'
when ISNULL(s.tip, -1) = 2 then '?????????? ?? ?????????? ?????'
WHEN ISNULL(s.tip, -1) = 3 then '?????????? ?? ?????????? ???'
when ISNULL(s.tip, -1) = 4 then '?????????? c ??????? ?????????? ?????' 
when ISNULL(s.tip, -1) = 5 then '???????? ??????????' end tip_name,
ISNULL(d.dname, '<??????????>') dname,
ISNULL(mrs.sogl, -1) sogl
from
(
) s
left join deps d on d.depid = s.depid
left join dbo.MarketRequestSogl mrs on mrs.mrid = @mrid and mrs.depid = s.depid*/

--drop table #res

DROP TABLE #wr
drop table #t
END