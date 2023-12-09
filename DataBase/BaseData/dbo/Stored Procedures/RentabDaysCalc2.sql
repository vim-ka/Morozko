CREATE PROCEDURE dbo.RentabDaysCalc2 @day0 datetime, @day1 datetime, @pin int, @calctip int, @vend int, @onlypin bit
AS
BEGIN
declare
@dn1 int,
@dn2 int,
@master int

select @master = master from dbo.def where pin = @pin
--set @date_from = '01.04.2017'
--set @date_to = '30.04.2017 23:59:59'
--set @calctip = 2 --покупатель
--set @pin = 43849

set @dn1 = dbo.InDatNom(0000, @day0)
set @dn2 = dbo.InDatNom(9999, @day1)

if @pin = -1 set @onlypin = 0

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
  
/*if object_id('tempdb..#o') is not null drop table #o
create table #o(hitag int, pin int)
insert into #o  
select
nv.Hitag, NC.b_id
from
dbo.nc nc
inner join dbo.nv nv on nv.datnom = nc.datnom
inner join #pin pn on pn.pin = nc.b_id
where nc.datnom >= @dn1 and nc.datnom <= @dn2
and nv.kol > 0
group by nv.Hitag, NC.b_id
select * from #o*/

if object_id('tempdb..#vend') is not null drop table #vend
create table #vend(ncod int)
if @vend = -1
	insert into #vend select ncod from dbo.vendors
else
	insert into #vend select @vend;

--select * from #vend

  if object_id('tempdb..#i') is not null drop table #i
  if object_id('tempdb..#f') is not null drop table #f  
   
  create table #i(datepost datetime, ncom int, hitag int, kold int)
  insert into #i(datepost, ncom, hitag, kold)
  select distinct i.nd, i.ncom, i.hitag, 1 from dbo.inpdet i
  inner join dbo.comman c on c.Ncom = i.ncom
  inner join #vend vnd on vnd.ncod = c.ncod
  where i.nd >= @day0 and i.nd <= @day1
  --group by i.nd, i.ncom, i.hitag
  
--  select * from #i

  create table #f(datepost datetime, kold int, ncom int, hitag int)
  insert into #f
  select a.DatePost, count(distinct a.WorkDate), a.ncom, a.hitag
  from
  MorozArc..ArcVI a
  inner join nomen n on n.hitag = a.hitag
  inner join gr g on g.ngrp = n.ngrp
  inner join SkladList sl on sl.SkladNo = a.Sklad
  inner join #vend vnd on vnd.ncod = a.ncod
  where a.WorkDate >= @day0 and a.WorkDate <= @day1
  and sl.Discard = 0
--  and a.Ncod = @vend
  group by a.DatePost, a.ncom, a.hitag
  
--  select * from #f  

  update #i set kold = (select isnull(kold, 1) from #f where #i.datepost = #f.datepost and #i.hitag = #f.hitag and #i.ncom = #f.ncom)
  
--  select * from #i    
  print 'STAGE CALC FINISHED'

--  if object_id('tempdb..#rcd') is not null drop table #rcd
--  create table #rcd(date_from datetime, date_to datetime, obl_id int, days int, pin int, mainparent int)  
--  insert into #rcd

--  truncate table dbo.rentabdays2
  delete from dbo.rentabdays2 where date_from = convert(varchar, @day0, 4) and date_to = convert(varchar, @day1, 4) and pin = @pin
  print 'STAGE DEL FINISHED'

  insert into dbo.rentabdays2
  select @day0, convert(varchar, @day1, 4), avg(isnull(#i.kold, 1)), @pin, g.mainparent, #i.hitag, rb2.ncod from 
--  obl o,
  #i
  inner join nomen n on n.hitag = #i.hitag
  inner join gr g on g.ngrp = n.ngrp
  inner join dbo.rentabbase2 rb2 on rb2.hitag = #i.hitag and rb2.pin = @pin
  --inner join visual v on v.hitag = #i.hitag
  --inner join skladlist sl on sl.SkladNo = v.sklad 
  inner join #vend vnd on vnd.ncod = rb2.ncod     
  --inner join dbo.rentabbase2 rb2 on rb2.hitag = #i.hitag AND rb2.pin = @pin
--  inner join #pin pn on pn.pin = rb2.pin
  --where
  --sl.Discard = 0
--  and v.ncod = @vend
  group by g.mainparent, #i.hitag, rb2.ncod  
  having avg(#i.kold) is not null
--  having avg(isnull(#i.kold, 1)) > 0

  print 'STAGE INS FINISHED'  
--  select * from #rcd order by #rcd.obl_id, #rcd.mainparent
END