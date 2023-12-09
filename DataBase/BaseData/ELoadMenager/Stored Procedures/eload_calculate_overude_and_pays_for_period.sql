create procedure eloadmenager.eload_calculate_overude_and_pays_for_period
@nd1 datetime, @nd2 datetime
as
begin
set nocount on
if object_id('tempdb..#base') is not null drop table #base
create table #base(base_id int identity(1,1) not null, 
									 dck int not null default 0,
									 depname nvarchar(100) not null default '',
                   agent_fio nvarchar(150) not null default '',
                   overdue money not null default 0,
                   from_agent money not null default 0,
                   from_bank money not null default 0)
create nonclustered index base_idx on #base(dck)                   

insert into #base (dck,depname,agent_fio)
select dc.dck,d.dname,p.fio
from dbo.defcontract dc 
join dbo.agentlist a on a.ag_id=dc.ag_id
join dbo.deps d on d.depid=a.depid
join dbo.person p on p.p_id=a.p_id
where dc.actual=1 --or exists(select 1 from dbo.kassa1 where iif(bank_id>0,bankday,nd) between @nd1 and @nd2)
group by dc.dck,d.dname,p.fio

update b set b.overdue=x.overdue
from #base b 
join (select a.dck, a.overdue from dbo.dailysaldodck a where a.nd=@nd2) x on x.dck=b.dck

update b set b.from_agent=x.agent, b.from_bank=x.bank
from #base b 
join (select a.dck, sum(iif(a.bank_id>0,0,a.plata)) [agent], sum(iif(a.bank_id>0,a.plata,0)) [bank] 
			from dbo.kassa1 a where a.oper=-2 and iif(a.bank_id>0,a.bankday,a.nd) between @nd1 and @nd2
      group by a.dck) x on x.dck=b.dck
                   
select depname [отдел], agent_fio [агент], sum(overdue) [просрочка],
       sum(from_agent) [через_агента], sum(from_bank) [через_банк]
from #base
group by depname, agent_fio
order by depname, agent_fio

select depname [отдел], sum(overdue) [просрочка],
       sum(from_agent) [через_агента], sum(from_bank) [через_банк]
from #base
group by depname
order by depname


if object_id('tempdb..#base') is not null drop table #base
set nocount off
end