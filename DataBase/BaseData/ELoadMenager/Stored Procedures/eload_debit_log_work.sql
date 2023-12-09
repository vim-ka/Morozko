CREATE procedure ELoadMenager.eload_debit_log_work
@dt1 datetime,
@dt2 datetime,
@op int=0
as
begin
if object_id('tempdb..#base') is not null drop table #base
create table #base (n int, dt datetime, pin int, brname nvarchar(500), deep int, overdue money, remark nvarchar(500), dt_sheet datetime, 
									  payment_sheet money, payment_kassa money, det_id int)
create nonclustered index base_idx on #base(pin)
insert into #base
select row_number() over(order by d.dt, f.brname), convert(nvarchar,d.dt,104) [dt], j.pin, f.brname, d.deep, d.overdue, d.remark,
			 (select max(p.nd) from tax.payments p where p.job_id=d.job_id and convert(varchar,d.dt,104)<=p.nd), (select sum(p.payment) from tax.payments p where p.job_id=d.job_id and convert(varchar,d.dt,104)<=p.nd),
       0, d.job_detail_id
from tax.job_detail d
join tax.job_types_list l on l.id=d.job_type
join tax.job j on j.job_id=d.job_id
join dbo.def f on f.pin=j.pin
where d.dt between @dt1 and @dt2+'23:59:59' 
			and d.op=iif(@op=0,d.op,@op) and d.job_type=0
      and l.tech_job=0 and d.isdel=0

update b set b.payment_kassa=x.[sm]
from #base b 
join (
select a.det_id, sum(k.plata) [sm]
from #base a
join dbo.kassa1 k on a.pin=k.b_id
join dbo.nc c on k.sourdatnom=c.datnom
where ((k.nd between @dt1 and @dt2)and(k.bank_id=0))or((k.bankday between @dt1 and @dt2)and(k.bank_id>0))
			and datediff(day,c.nd,iif(k.bank_id=0,k.nd,k.bankday))>c.srok+1 
      and iif(k.bank_id=0,k.nd,k.bankday)>=a.dt
      and k.oper=-2 
group by a.det_id) x on x.det_id=b.det_id

select * from #base

if object_id('tempdb..#base') is not null drop table #base
end