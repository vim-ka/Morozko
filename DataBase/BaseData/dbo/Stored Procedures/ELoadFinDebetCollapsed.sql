CREATE PROCEDURE dbo.ELoadFinDebetCollapsed
@nd datetime,
@deps varchar(500)
AS
BEGIN
declare @y datetime

set @y= case when @nd=dbo.today() then DATEADD(day,-1,@nd) else @nd end

create table #tdeps (depid int)
if @deps<>''
begin
	declare @sql varchar(max)
	set @sql=''
	set @sql='insert into #tdeps select '+replace(@deps,',',' union all select ')
	exec(@sql)
end
else
begin
	insert into #tdeps
  select depid
  from deps s
  where s.Sale=1
end

create table #saldoDck(DepID int, pin int, debt money, overdue money, overup17 money)
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
  inner join #tdeps t on t.depid=a.depid
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

select x.depid, 
			 x.dname, 
       x.sumdept, 
       x.sover, 
       ROUND((x.sover / x.sumdept * 1.00 )*100, 0) [sover%], 
       x.sover17, 
       ROUND((x.sover17 / x.sumdept * 1.00 )*100, 0) [sover17%]
from (
  select 	d.DepID,
          d.DName,
          sum(x.debt) [sumdept],
          sum(x.overdue) [sover],
          sum(x.overup17) [sover17]
  from #saldoDck x
  join deps d on x.depid=d.DepID
	group by d.depid,d.dname 
) x
order by 1

drop table #saldodck
drop table #tdeps
END