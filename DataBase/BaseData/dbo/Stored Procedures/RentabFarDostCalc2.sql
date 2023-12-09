CREATE PROCEDURE dbo.RentabFarDostCalc2 @day0 datetime, @day1 datetime, @pin int, @calctip int, @vend int, @onlypin bit
AS
BEGIN
  declare
  @dn0 int,
  @dn1 int,
  @master int
  select @master = master from dbo.def where pin = @pin
  
  set @dn0 = dbo.InDatNom(0000, @day0)
  set @dn1 = dbo.InDatNom(9999, @day1)  

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

--select * from #vend

--  truncate table dbo.rentabfardost2
delete from dbo.rentabfardost2 where date_from = convert(varchar, @day0, 4) and date_to = convert(varchar, @day1, 4) and pin = @pin

insert into dbo.rentabfardost2(date_from, date_to, fardost_koeff, mainparent, pin, hitag, ncod)
select @day0, convert(varchar, @day1, 4), round(avg(i.cost_delivery_1kg), 2) cost_delivery_1kg, g.mainparent, @pin, i.hitag, c.ncod from dbo.Inpdet i  
inner join dbo.comman c on c.Ncom = i.ncom
inner join #vend vnd on vnd.ncod = c.ncod
inner join dbo.nomen n on n.hitag = i.hitag
inner join dbo.gr g on g.Ngrp = n.ngrp
where i.nd >= @day0 and i.nd <= @day1
group by g.mainparent, i.hitag, c.ncod
  
END