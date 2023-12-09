CREATE PROCEDURE dbo.ELoadFinDebet
@nd datetime
AS
BEGIN
declare @y datetime

set @y= case when @nd=dbo.today() then DATEADD(day,-1,@nd) else @nd end

if object_id('tempdb.dbo.#saldoDck') is not null
	drop table #saldodck

create table #saldoDck(DepID int, pin int, debt money, overdue money, overup17 money)
create index sld_idx on #saldoDck(pin) 
insert into #saldoDck
SELECT
  A.depid, 
	dc.pin, 
	sum(s.debt) as Debt, 
	sum(s.overdue) as Overdue, 
	sum(OverUp17) as OverUp17
from 
  dailysaldodck  s
  inner join defcontract dc on dc.dck=s.dck
  inner join Agentlist A on A.ag_id=dc.ag_id
where
  s.nd = @y
  and a.depid>0 
group by A.depid,dc.pin
having sum(s.debt)>0.01 or sum(s.overdue)>0.01

if @nd=dbo.today()
begin
	update #saldoDck set debt=debt-y.pl
	from #saldoDck x 
	inner join ( select b_id, sum(plata) pl from Kassa1 where nd=dbo.today() group by b_id) y on x.pin=y.b_id
	
	update #saldoDck set debt=debt+y.ot
	from #saldoDck x 
	inner join ( select b_id, sum(sp) ot from nc where nd=dbo.today() group by b_id) y on x.pin=y.b_id
end

select 	d.DepID,
				d.DName,
				de.pin,
				de.brName,
				x.debt,
				x.overdue,
				x.overup17
from #saldoDck x
join deps d on x.depid=d.DepID
join def de on de.pin=x.pin
order by 1,4

drop table #saldodck
END