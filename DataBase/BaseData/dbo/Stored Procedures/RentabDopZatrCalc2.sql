CREATE PROCEDURE dbo.RentabDopZatrCalc2 @date_from datetime, @date_to datetime, @pin int, @calctip int, @onlypin bit, @depid INT = -1, @ag_id INT = -1
AS
BEGIN
  declare @master int

--set @pin = 53030
--set @calctip = 2
--set @onlypin = 0

if object_id('tempdb..#ags') is not null drop table #ags
create table #ags(ag_id int)
IF @depid = -1
  INSERT INTO #ags SELECT al.ag_id FROM dbo.AgentList al 
  inner join dbo.person p on p.p_id = al.p_id and p.depid = al.depid
  WHERE al.AG_ID = @ag_id AND al.P_ID <> 0 and p.closed = 0
else
begin
  IF @ag_id = -1
    INSERT INTO #ags SELECT al.ag_id FROM dbo.AgentList al 
    inner join dbo.person p on p.p_id = al.p_id and p.depid = al.depid
    WHERE al.depid = @depid AND al.P_ID <> 0 and p.closed = 0
  else
    INSERT INTO #ags SELECT al.ag_id FROM dbo.AgentList al 
    inner join dbo.person p on p.p_id = al.p_id and p.depid = al.depid
    WHERE al.depid = @depid AND al.AG_ID = @ag_id AND al.P_ID <> 0 and p.closed = 0
end
IF @depid = -1 AND @ag_id = -1
  INSERT INTO #ags SELECT ag_id FROM dbo.AgentList al WHERE al.P_ID <> 0

if @pin = -1 set @onlypin = 0

select @master = master from dbo.def where pin = @pin

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


delete from dbo.RentabDopZatr2 where date_from = convert(varchar, @date_from, 4) 
and date_to = convert(varchar, @date_to, 4) and calctip = @calctip and pin = @pin

INSERT INTO dbo.RentabDopZatr2

select distinct @date_from, convert(varchar, @date_to, 4), @pin, @calctip, isnull(iif(rbb2.cnt = 0, dz.sumz, dz.sumz / rbb2.cnt), 0) sumz --, fr.* 
from dbo.FrizRequest fr
inner join dbo.FrizNeedAction fna on fna.fnaId = fr.rneedact
inner join (SELECT pin FROM #pin GROUP BY pin) pn on pn.pin = fr.rtpcode
INNER JOIN #ags ON #ags.ag_id = #pin.ag_id
left join (select frid, isnull(sum(kol * price), 0) sumz from dbo.FrizRequestDopZatr group by frid) dz on dz.frid = fr.rcmplxid
left join (select pin, date_from, date_to, count(*) cnt from dbo.rentabbase2 group by pin, date_from, date_to) rbb2 on rbb2.pin = @pin 
and rbb2.date_from = cast(@date_from as date) and rbb2.date_to = cast(@date_to as date)
where
fr.rdt >= @date_from and fr.rdt <= @date_to
and fna.fnaId in (1, 2)


END