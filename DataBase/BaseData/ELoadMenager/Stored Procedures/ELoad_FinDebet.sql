CREATE PROCEDURE ELoadMenager.ELoad_FinDebet
@nd datetime,
@deps varchar(500)
AS
BEGIN
declare @y datetime

set @y= case when @nd=dbo.today() then DATEADD(day,-1,@nd) else @nd end

create table #tdeps (depid int)
if @deps<>'' insert into #tdeps select value from string_split(@deps,',')
else insert into #tdeps select depid from dbo.deps s where s.Sale=1

if object_id('tempdb.dbo.#saldoDck') is not null
	drop table #saldodck

create table #saldoDck(DepID int, pin int, debt money, overdue money, overup17 money, deep int)
create index sld_idx on #saldoDck(pin) 
insert into #saldoDck
select A.depid, dc.pin, sum(s.debt) as Debt, sum(s.overdue) as Overdue, sum(OverUp17) as OverUp17, max(deep) [deep]
from dbo.dailysaldodck  s
inner join dbo.defcontract dc on dc.dck=s.dck
inner join dbo.Agentlist A on A.ag_id=dc.ag_id
inner join #tdeps t on t.depid=a.depid
where s.nd = @y and a.depid>0 
group by A.depid,dc.pin
having sum(s.debt)>0.01 or sum(s.overdue)>0.01

if @nd=dbo.today()
begin
	update #saldoDck set debt=debt-y.pl
	from #saldoDck x 
	inner join (select b_id, sum(plata) pl from dbo.kassa1 where nd=@nd group by b_id) y on x.pin=y.b_id
	
	update #saldoDck set debt=debt+y.ot
	from #saldoDck x 
	inner join (select b_id, sum(sp) ot from dbo.nc where nd=@nd group by b_id) y on x.pin=y.b_id
  
  update #saldoDck set Overdue=Overdue+y.ot, deep=deep+iif(y.ot>0,1,0)
	from #saldoDck x 
	inner join (select b_id, sum(sp-fact+izmen) ot from dbo.nc where dateadd(day,srok+1,nd)=@nd group by b_id) y on x.pin=y.b_id
  
  update #saldoDck set Overup17=Overup17+y.ot
	from #saldoDck x 
	inner join (select b_id, sum(sp-fact+izmen) ot from dbo.nc where dateadd(day,srok+17,nd)=@nd group by b_id) y on x.pin=y.b_id
end

select 	d.DepID [КодОтдела],
				d.DName [НаименованиеОтдела],
				de.pin [КодКлиента],
				de.brName [НаименованиеКлиента],
				x.debt [Задолженность],
				x.overdue [Просрочка],
				x.overup17 [Просрочка17],
        x.deep [Глубина]
from #saldoDck x
join deps d on x.depid=d.DepID
join def de on de.pin=x.pin
order by 1,4

select x.depid [КодОтдела], 
			 x.dname [НаименованиеОтдела], 
       x.sumdept [СуммаЗадолженности], 
       x.sover [СуммаПросрочки], 
       ROUND((x.sover / x.sumdept * 1.00 )*100, 0) [ПроцентПросрочки], 
       x.sover17 [СуммаПросрочки17], 
       ROUND((x.sover17 / x.sumdept * 1.00 )*100, 0) [ПроцентПросрочки17]
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

--select * from #tdeps

drop table #saldodck
drop table #tdeps
END