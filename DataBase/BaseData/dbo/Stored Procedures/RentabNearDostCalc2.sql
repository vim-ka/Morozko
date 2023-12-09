CREATE PROCEDURE dbo.RentabNearDostCalc2 @day0 datetime, @day1 datetime, @pin int, @calctip int, @vend int, @onlypin bit,
@depid INT = -1, @ag_id INT = -1
AS
BEGIN
  declare
  @dn0 int,
  @dn1 int,
  @master int
  select @master = master from dbo.def where pin = @pin
  
  set @dn0 = dbo.InDatNom(0000, @day0)
  set @dn1 = dbo.InDatNom(9999, @day1)  

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

if object_id('tempdb..#vend') is not null drop table #vend
create table #vend(ncod int)
if @vend = -1
	insert into #vend select ncod from dbo.vendors
else
	insert into #vend select @vend;

--select * from #vend
  
  if object_id('tempdb..#m') is not null drop table #m
  if object_id('tempdb..#s') is not null drop table #s  
  if object_id('tempdb..#cf') is not null drop table #cf
      
  create table #m(nd datetime, marsh int, plata money, weight decimal(18, 3), obl_id int, b_id int, hitag int, ncod int)
  create table #s(nd datetime, marsh int, sp money, obl_id int, b_id int)    

  exec NearLogistic.Marsh2CalcFact @day0, @day1 
  create table #cf(cfact int, mhid int)
  insert into #cf(cfact, mhid)
  select sm, mhid from dbo.Marsh2CalcFact
  create index tempcf on #cf(mhid)
  
  insert into #m(nd, marsh, plata, weight, b_id, hitag, ncod)
  select m.nd, m.Marsh, #cf.cfact, isnull(m.Weight, 0) + isnull(m.dopWeight, 0), nc.b_id, nv.hitag, v.ncod
  from marsh m
  inner join #cf on #cf.mhid = m.mhid
--  inner join dbo.nc nc on nc.nd = m.nd and nc.marsh = m.marsh
  inner join dbo.nc nc on nc.mhid = m.mhid
  inner join dbo.nv nv on nv.datnom = nc.datnom
  inner join dbo.visual v on v.id = nv.TekID
--        where m.nd >= @day0 and m.nd <= @day1
  inner join #vend vnd on vnd.ncod = v.ncod
  inner join (SELECT pin FROM #pin GROUP BY pin) pn on pn.pin = nc.b_id
  INNER JOIN #ags ON #ags.ag_id = nc.ag_id  
  where nc.datnom >= @dn0 and nc.datnom <= @dn1
  and m.Marsh not in (0, 99)
  and nc.RefDatnom = 0
  and nc.Tara = 0 and nc.Frizer = 0
  and isnull(m.Weight, 0) + isnull(m.dopWeight, 0) > 0
--  and v.ncod = @vend
  group by m.nd, m.Marsh, m.Weight, m.dopWeight, nc.b_id, #cf.cfact, nv.hitag, v.ncod
  create index tempm on #m(b_id)
  create index tempm2 on #m(marsh)      
        
  insert into #s(nd, marsh, sp, obl_id, nc.b_id)
  select 
  nc.nd, nc.Marsh, sum(sp) sp, isnull(d.Obl_ID, 0), nc.b_id
  from nc
  inner join def d on d.pin = nc.B_ID
  inner join (SELECT pin FROM #pin GROUP BY pin) pn on pn.pin = nc.b_id
  INNER JOIN #ags ON #ags.ag_id = nc.ag_id
--        where nc.nd >= @day0 and nc.nd <= @day1
  where nc.datnom >= @dn0 and nc.datnom <= @dn1
  and nc.RefDatnom = 0 and nc.marsh not in (0, 99)
  and nc.Tara = 0 and nc.Frizer = 0
  group by nc.nd, nc.Marsh, d.Obl_ID, nc.b_id
  create index temps on #s(b_id)
  create index temps2 on #s(marsh)      

  update #m set #m.obl_id = (select top 1 obl_id from #s where #s.nd = #m.nd and #s.marsh = #m.marsh and #s.b_id = #m.b_id order by #s.sp desc)
  
--  truncate table dbo.rentabneardost2
delete from dbo.rentabneardost2 where 
exists(select * from dbo.rentabneardost2 where date_from = convert(varchar, @day0, 4) and date_to = convert(varchar, @day1, 4) and pin = @pin)

  insert into dbo.rentabneardost2(date_from, date_to, neardost_koeff, mainparent, pin, hitag, ncod)
  select @day0, convert(varchar, @day1, 4), round(sum(plata) / sum(isnull(weight, 1)), 2) koeff, -1 mainparent, @pin, #m.hitag, #m.ncod from #m
  where #m.plata > 0 and #m.plata is not null and #m.weight is not null and #m.weight > 0
  group by #m.hitag, #m.ncod    
  
  select * from	dbo.rentabneardost2  
END