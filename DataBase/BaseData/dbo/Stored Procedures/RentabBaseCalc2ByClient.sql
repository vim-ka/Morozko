CREATE PROCEDURE dbo.RentabBaseCalc2ByClient @date_from datetime, @date_to datetime, @calctip int, @pin int, @vend int, @onlypin bit, @ngrp int, @fg int = -1,
@depid INT = -1, @ag_id INT = -1
AS
BEGIN
--set nocount on

declare
@dn1 int,
@dn2 int,
@master int

--set @date_from = '01.04.2017'
--set @date_to = '30.04.2017 23:59:59'
--set @calctip = 2 --покупатель
--set @pin = 43849

set @dn1 = dbo.InDatNom(0001, @date_from)
set @dn2 = dbo.InDatNom(9999, @date_to)
if @pin = -1 set @onlypin = 0

select @master = master from dbo.def where pin = @pin

if object_id('tempdb..#ags') is not null drop table #ags
create table #ags(ag_id int)
IF @depid = -1
  INSERT INTO #ags SELECT ag_id FROM dbo.AgentList al WHERE al.AG_ID = @ag_id AND al.P_ID <> 0
else
begin
  IF @ag_id = -1
    INSERT INTO #ags SELECT ag_id FROM dbo.AgentList al WHERE al.depid = @depid AND al.P_ID <> 0
  else
    INSERT INTO #ags SELECT ag_id FROM dbo.AgentList al WHERE al.depid = @depid AND al.AG_ID = @ag_id AND al.P_ID <> 0
end
IF @depid = -1 AND @ag_id = -1
  INSERT INTO #ags SELECT ag_id FROM dbo.AgentList al WHERE al.P_ID <> 0

--SELECT * FROM #ags ORDER BY ag_id

if object_id('tempdb..#oi') is not null drop table #oi
create table #oi(our_id int)
if @fg = -1
  insert into #oi select our_id from dbo.FirmsConfig where actual = 1
else
  insert into #oi select our_id from dbo.FirmsConfig where actual = 1 and FirmGroup = @fg

if object_id('tempdb..#pin') is not null drop table #pin
create table #pin(pin int)

if object_id('tempdb..#ulpin') is not null drop table #ulpin
create table #ulpin(pin int)      
insert into #ulpin
select ncod from RentabUrLicaDet where ruid in (select rul.id from RentabUrLica rul inner join RentabUrLicaDet ruld on ruld.ruid = rul.id where ruld.ncod = @pin)

if @pin <> -1 
begin
  if @onlypin = 0
      insert into #pin 
      select distinct def.pin from dbo.def 
      inner join dbo.defcontract dc on dc.pin = def.pin
      where 
      dc.ContrTip not in (5, 7)
      and ((def.master in (select pin from #ulpin) or (def.master = @master and @master <> 0)) or def.pin in (select pin from #ulpin)) or def.pin = @pin
      and def.Worker = 0
  else
      insert into #pin select @pin;
end
else
  insert into #pin 
  select distinct def.pin from dbo.def 
  inner join dbo.defcontract dc on dc.pin = def.pin
  where 
  dc.ContrTip not in (5, 7)
  and def.Worker = 0

if object_id('tempdb..#vend') is not null drop table #vend
create table #vend(ncod int)
if @vend = -1
	insert into #vend select ncod from dbo.vendors
else
	insert into #vend select @vend;
    
if object_id('tempdb..#tgr') is not null drop table #tgr
create table #tgr(ngrp int)
if @ngrp = -1
	insert into #tgr select ngrp from dbo.gr where ngrp = mainparent
else    
	insert into #tgr select @ngrp    

--select * from #vend
--select * from #tgr

if object_id('tempdb..#upr') is not null drop table #upr
create table #upr(hitag int, price numeric(12, 2), cost numeric(12, 2), cnt int, allcnt int, uvp numeric(12, 2), uvc numeric(12, 2))
insert into #upr 
select
nv.hitag, nv.price, nv.cost, count(*) * nv.Kol, 0, 0.0, 0.0
from
nc
inner join nv on nv.datnom = nc.datnom
inner join #pin on #pin.pin = nc.b_id
inner join dbo.visual v on v.id = nv.TekID 
inner join #vend vnd on vnd.ncod = v.ncod
INNER JOIN #ags a ON a.ag_id = nc.Ag_Id
where
nc.datnom >= @dn1 and nc.datnom <= @dn2
group by nv.hitag, nv.price, nv.cost, nv.kol

--select @allcnt = sum(uv) from #upr
--print @allcnt

update #upr set allcnt = (select sum(u.cnt) from #upr u where u.hitag = #upr.hitag group by u.hitag)
update #upr set uvp = price * cnt / iif(allcnt = 0, 1, cast(allcnt as numeric(18, 3))), uvc = cost * cnt / iif(allcnt = 0, 1, cast(allcnt as numeric(18, 3)))

if object_id('tempdb..#u') is not null drop table #u
create table #u(hitag INT, uvc NUMERIC(12, 2), uvp NUMERIC(12, 2))
insert into #u 
select 
--hitag, price, sum(uvp) uvp, sum(uvc) uvc, allcnt
hitag, sum(uvc) uvc, sum(uvp) uvp
from #upr 
--where hitag = 26842
group by hitag

if object_id('tempdb..#basecalc') is not null drop table #basecalc
create table #basecalc(date_from datetime, date_to datetime, calctip int, pin int, nds numeric(5, 2), datnom int, refdatnom int, 
	postvol numeric(18, 3), postvol2 numeric(18, 3), sumcost numeric(18, 3), sumprice numeric(18, 3), avgcost numeric(18, 3), avgprice numeric(18, 3),
    postvol_kol numeric(18, 3), postvol2_kol numeric(18, 3), real_pin int)

insert into #basecalc    
select
	convert(varchar, @date_from, 4),
    convert(varchar, @date_to, 4),
    @calctip,
    @pin,
    n.nds,
    nv.datnom,
    nc.RefDatnom,
--    sum(IIF(v.weight = 0, n.Netto, v.weight) * (nv.kol - nv.Kol_B)) postvol,
--    sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol) postvol2,
	sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol) postvol,
	sum(IIF(v.weight = 0, n.Netto, v.weight) * iif(nv.kol >= 0, nv.kol, 0)) postvol2,
	round((sum(nv.cost * nv.kol * (1 + nc.Extra / 100))) / (sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol)), 2) sumcost,
    round((sum(nv.price * nv.kol * (1 + nc.Extra / 100))) / (sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol)), 2) sumprice,
    --round((sum(nv.cost * nv.kol * (1 + nc.Extra / 100))) / (sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol)) / sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol), 2),
    --round((sum(nv.price * nv.kol * (1 + nc.Extra / 100))) / (sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol)) / sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol), 2), 
	--avg(nv.Cost),    
--    iif(sum(u.uvc) is null, avg(nv.Cost), sum(u.uvc)) cost,
    (select IIF(uvc is null, avg(nv.Cost), uvc) from #u where hitag = nv.Hitag) cost,
    --avg(nv.Price),
--    iif(sum(u.uvp) is null, avg(nv.Price), sum(u.uvp)) price,    
    (select IIF(uvp is null, avg(nv.Price), uvp) from #u where hitag = nv.Hitag) price,
--    sum(nv.kol - nv.Kol_B) postvol_kol,
--    sum(nv.kol) postvol2_kol   
    sum(nv.kol) postvol_kol,
    sum(iif(nv.kol >= 0, nv.kol, 0)) postvol2_kol,
--    iif(n.flgweight = 1, sum(IIF(v.weight = 0, n.Netto, v.weight) * (nv.kol - nv.Kol_B)), sum(nv.kol - nv.Kol_B)) postvol_kol,
--    iif(n.flgweight = 1, sum(IIF(v.weight = 0, n.Netto, v.weight) * (nv.kol)), sum(nv.kol)) postvol_kol2
    nn.b_id
from
    dbo.nv nv    
inner join dbo.nc nc on nc.DatNom = nv.DatNom    
inner join dbo.def d on d.pin = nc.B_ID
INNER JOIN dbo.defcontract dc ON dc.DCK = nc.DCK
inner join dbo.nomen n on n.hitag = nv.hitag
inner join dbo.gr g on g.Ngrp = n.ngrp
inner join dbo.visual v on v.id = nv.TekID 
--inner join (select hitag, ncod from dbo.NomenVend group by hitag, ncod) nomv on nomv.Hitag = nv.hitag
inner join #vend vnd on vnd.ncod = v.ncod
inner join #pin pn on pn.pin = nc.b_id
inner join #tgr tgr on tgr.ngrp = g.MainParent
inner join #oi on #oi.our_id = nc.OurID
--inner join #u u on u.hitag = nv.hitag
INNER JOIN #ags a ON a.ag_id = nc.Ag_Id
INNER JOIN (SELECT b_id, datnom FROM dbo.nc) nn ON nn.datnom = nv.datnom and nn.b_id = nc.b_id
where
	nc.DatNom >= @dn1 and nc.DatNom <= @dn2	
and nc.tara = 0 and nc.frizer = 0    
AND dc.ContrTip not in (5, 7)
--and dc.pin = nc.b_id
--and nv.kol > 0
and n.netto <> 0
--and v.weight <> 0
--and nc.RefDatnom = 0
--and nc.b_id in (select pin from #pin)
group by           
	nv.Hitag,
    g.mainparent,
    --d.Obl_ID,
    n.nds,
    nv.datnom, nc.RefDatnom,
    v.Ncod, n.flgWeight, nn.b_id
having sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol) <> 0 
print '#basecalc - ok'
--select * from #basecalc

if object_id('tempdb..#actncalc') is not null drop table #actncalc
create table #actncalc(hitag int, postvol_kol numeric(18, 3), postvol2_kol numeric(18, 3), ncod int, mainparent int, datnom int)

insert into #actncalc    
select
	nv.Hitag,
    sum(nv.kol - nv.Kol_B) postvol_kol,
    sum(nv.kol) postvol2_kol,
    v.ncod,
    g.MainParent,
    nv.datnom   
from
    dbo.nv nv    
inner join dbo.nc nc on nc.DatNom = nv.DatNom    
inner join dbo.def d on d.pin = nc.B_ID
INNER JOIN dbo.defcontract dc ON dc.DCK = nc.DCK
inner join dbo.nomen n on n.hitag = nv.hitag
inner join dbo.gr g on g.Ngrp = n.ngrp
inner join dbo.visual v on v.id = nv.TekID 
--inner join (select hitag, ncod from dbo.NomenVend group by hitag, ncod) nomv on nomv.Hitag = nv.hitag
inner join #vend vnd on vnd.ncod = v.ncod
inner join #pin pn on pn.pin = nc.b_id
inner join #tgr tgr on tgr.ngrp = g.MainParent
inner join #oi on #oi.our_id = nc.OurID
--inner join #u u on u.hitag = nv.hitag
INNER JOIN #ags a ON a.ag_id = nc.Ag_Id
where
	nc.DatNom >= @dn1 and nc.DatNom <= @dn2	
and nc.tara = 0 and nc.frizer = 0    
AND dc.ContrTip not in (5, 7)
--and dc.pin = nc.b_id
--and nv.kol > 0
and n.netto <> 0
--and v.weight <> 0
and nc.RefDatnom = 0
--and nc.b_id in (select pin from #pin)
and nc.Actn = 1
and nc.stip = 3
group by           
	nv.Hitag, v.ncod, g.MainParent, nv.datnom
--having sum(IIF(v.weight = 0, n.Netto, v.weight) * nv.kol) <> 0   
print '#actncalc - ok'

--TRUNCATE TABLE dbo.rentabbase2
delete from dbo.rentabbase2byclient where date_from = convert(varchar, @date_from, 4) 
and date_to = convert(varchar, @date_to, 4) and calctip = @calctip and pin = @pin and fg = @fg

INSERT INTO dbo.rentabbase2byclient
SELECT
  r.date_from,
  r.date_to,
  r.calctip,
  r.pin,
  SUM(r.postvol) s_postvol,
  SUM(r.postvol2) s_postvol2,
  sum(r.postvol_kol) * avg(r.avgcost) s_cost,
  sum(r.postvol_kol) * avg(r.avgprice) s_price,  
  case when sum(r.postvol_kol) * avg(r.avgcost) = 0 then 0 else
  sum(r.postvol_kol) * (avg(r.avgprice) - avg(r.avgcost)) / (sum(r.postvol_kol) * avg(r.avgcost)) * 100 end naz_proc,
--  sum(r.postvol_kol) * avg(r.avgprice) - sum(r.postvol_kol) * avg(r.avgcost) naz_with_nds,
  sum(r.postvol_kol) * (avg(r.avgprice) - avg(r.avgcost)) naz_with_nds,
  AVG(iif(r.nds = 0, 10, r.nds)) nds,    
  case when (1 + AVG(r.nds) * 0.01) = 0 then 0 else
--  sum(r.postvol_kol) * avg(r.avgprice) - sum(r.postvol_kol) * avg(r.avgcost) / (1 + AVG(r.nds) * 0.01) end naz_withoutNDS,
  sum(r.postvol_kol) * (avg(r.avgprice) - avg(r.avgcost)) / (1 + AVG(r.nds) * 0.01) end naz_withoutNDS,  
--  sum((r.sumprice - r.sumcost) * r.postvol) / SUM(r.postvol) naz_kg,
  case when SUM(r.postvol) = 0 then 0 else
--  sum(r.postvol_kol) * avg(r.avgprice) - sum(r.postvol_kol) * avg(r.avgcost) / SUM(r.postvol) end naz_kg,
  sum(r.postvol_kol) * (avg(r.avgprice) - avg(r.avgcost)) / SUM(r.postvol) end naz_kg,
--  sum((r.sumprice - r.sumcost) * r.postvol) / SUM(r.postvol) / (1 + AVG(r.nds) * 0.01) naz_kg_withoutNDS,
  case when SUM(r.postvol) = 0 or (1 + AVG(r.nds) * 0.01) = 0 then 0 else
--  sum(r.postvol_kol) * avg(r.avgprice) - sum(r.postvol_kol) * avg(r.avgcost) / SUM(r.postvol) / (1 + AVG(r.nds) * 0.01) end naz_kg_withoutNDS,
  sum(r.postvol_kol) * (avg(r.avgprice) - avg(r.avgcost)) / SUM(r.postvol) / (1 + AVG(r.nds) * 0.01) end naz_kg_withoutNDS,
  avg(r.avgcost),
  avg(r.avgprice),
  sum(r.postvol_kol),
  sum(r.postvol2_kol), 
  0, --isnull((select sum(postvol_kol) from #actncalc where hitag = r.hitag and ncod = r.ncod), 0),
  0, --isnull((select sum(postvol2_kol) from #actncalc where hitag = r.hitag and ncod = r.ncod), 0),
  @fg,
  r.real_pin
FROM 
  #basecalc r
--  left join #rets rts on rts.pin = r.pin and rts.hitag = r.hitag and rts.ncod = r.ncod
  --left join #actncalc a on a.hitag = r.hitag and a.pin = r.pin and a.ncod = r.ncod and a.date_from = r.date_from and a.date_to = r.date_to
GROUP BY r.date_from, r.date_to, r.calctip, r.pin, r.real_pin
 --, r.obl_id, 
--having SUM(r.postvol_kol) <> 0 and SUM(r.postvol2_kol) <> 0 and avg(r.avgcost) <> 0 and AVG(r.nds) <> 0 and SUM(r.postvol2) <> 0
--SET NOCOUNT OFF

if object_id('tempdb..#basecalc') is not null drop table #basecalc
if object_id('tempdb..#actncalc') is not null drop table #actncalc
  
END