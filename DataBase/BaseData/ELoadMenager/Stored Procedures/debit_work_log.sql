CREATE PROCEDURE ELoadMenager.debit_work_log
@dt1 datetime,
@dt2 datetime,
@op int=0
as
begin
declare @over money
declare @over_end money
declare @plan money
declare @fact money
declare @p_over money
declare @p_over_end money
declare @p_plan money
declare @p_fact money

declare @nd1 datetime 
declare @nd2 datetime 
set @nd1=@dt1
set @nd2=@dt2
if @nd1=dbo.today() set @nd1=dateadd(day,-1,@nd1)
if @nd2=dbo.today() set @nd2=dateadd(day,-1,@nd2)
else set @nd2=dateadd(day,1,@nd2)
if object_id('tempdb..#kss') is not null drop table #kss
create table #kss (dck int, plata money)
if object_id('tempdb..#dck') is not null drop table #dck
create table #dck (dck int)
create nonclustered index dck_idx on #dck(dck)
insert into #dck 
select w.dck from tax.work_det wd 
join tax.works w on w.work_id=wd.work_id 
where wd.dt between @dt1 and @dt2 and wd.isdel=0 and wd.op=iif(@op=0,wd.op,@op)
group by w.dck
create nonclustered index kss_idx on #kss(dck)
insert into #kss
select k.dck, sum(k.plata) [plata] 
from dbo.kassa1 k
join #dck on #dck.dck=k.dck
join dbo.nc c on c.datnom=k.sourdatnom
join dbo.defcontract dc on dc.dck=c.dck
where k.nd between @nd1 and @nd2 and k.oper=-2 
			and datediff(day,dateadd(day,dc.srok+1,c.nd),iif(k.bank_id>0,k.bankday,k.nd))>5
            and datediff(day,dateadd(day,dc.srok+1,c.nd),iif(k.bank_id>0,k.bankday,k.nd))<30
group by k.dck
if object_id('tempdb..#sld_dck') is not null drop table #sld_dck
create table #sld_dck (dck int, deep int, overdue money, deep_end int, overdue_end money, plata money)
create nonclustered index sld_dck_idx on #sld_dck(dck)
insert into #sld_dck
select ds_begin.dck, ds_begin.deep, ds_begin.overdue, ds_end.deep_end, ds_end.overdue_end, k.[plata]
from dbo.dailysaldodck ds_begin
join #dck on ds_begin.dck=#dck.dck
left join #kss k on k.dck=ds_begin.dck
left join (select a.dck, a.deep [deep_end], a.overdue [overdue_end] from dbo.dailysaldodck a where a.nd=@nd2) ds_end on ds_end.dck=ds_begin.dck
where ds_begin.nd=@nd1

--set @over=isnull((select sum(overdue) from #sld_dck),0)
set @over=isnull(
					(
          select sum(ds.overdue) 
          from dbo.dailysaldodck ds 
          join (
          select w.dck, min(wd.dt) [dt]
          from tax.work_det wd 
          join tax.works w on w.work_id=wd.work_id
          join #dck on #dck.dck=w.dck
          where wd.dt between @dt1 and @dt2
                and wd.isdel=0 and wd.op=iif(@op=0,wd.op,@op)
          group by w.dck
                ) x on ds.dck=x.dck and dateadd(day,-1,ds.nd)=x.dt
					),0)
set @over_end=isnull((select sum(overdue_end) from #sld_dck),0)
set @fact=isnull((select sum(plata) from #sld_dck),0)
set @plan=isnull((select sum(p.payment) from tax.payments p
								  where p.work_id in (select distinct wd.work_id from tax.work_det wd 
                  										where wd.dt between @dt1 and @dt2 and wd.isdel=0 and wd.op=iif(@op=0,wd.op,@op))),0)
set @p_over=iif(@over=0, 0, 100)
set @p_over_end=iif(@over=0, 0, @over_end / @over) *100
set @p_fact=iif(@over=0, 0, @fact / @over) *100
set @p_plan=iif(@over=0, 0, @plan / @over) *100                                      

select deps.dname [отдел], a.ag_id [код_агента], sa.fio [агент], 
			 d.pin [код_клиента], d.brname [клиент], dc.dck [код_договора], dc.contrname [договор],         
       wd.dt [дата_работы], wt.list [тип_работы], u.uin [код_оператора], u.fio [оператор], wd.remark [комментарий],
			 --s.deep 
       ds.deep [глубина], s.deep_end [глубина_на_конец], 
       --s.overdue
       ds.overdue [просрочка], ds.overdue [просрочка_во_время_работы], 
       s.overdue_end [просрочка_на_конец], s.plata [оплаты_за_период],
       (select sum(a.payment) from tax.payments a where a.work_id=wd.work_id and a.nd between @dt1 and @dt2) [план_оплаты_за_период],
       @dt1 [#dt1], @dt2 [#dt2],
       isnull(@over,0) [#over], isnull(@over_end,0) [#over_end], isnull(@fact,0) [#fact], isnull(@plan,0) [#plan],
       isnull(@p_over,0) [#p_over], isnull(@p_over_end,0) [#p_over_end], isnull(@p_fact,0) [#p_fact], isnull(@p_plan,0) [#p_plan]
--into ##tmp_debit       
from tax.work_det wd 
join tax.works w on w.work_id=wd.work_id
left join dbo.dailysaldodck ds on ds.dck=w.dck and dateadd(day,-1,ds.nd)=wd.dt
join #sld_dck s on s.dck=w.dck
join dbo.usrpwd u on wd.op=u.uin
join dbo.defcontract dc on dc.dck=w.dck
join dbo.def d on d.pin=dc.pin
join dbo.agentlist a on a.ag_id=iif(dc.ag_id=33,dc.prevag_id,dc.ag_id)
join dbo.person sa on sa.p_id=a.p_id
join dbo.deps on deps.depid=a.depid
join tax.work_type_list wt on wt.id=wd.work_type_id
where wd.dt between @dt1 and @dt2
			and wd.isdel=0 and wd.op=iif(@op=0,wd.op,@op)
order by sa.fio, deps.dname, d.brname 
if object_id('tempdb..#sld_dck') is not null drop table #sld_dck
if object_id('tempdb..#dck') is not null drop table #dck
if object_id('tempdb..#kss') is not null drop table #kss
end