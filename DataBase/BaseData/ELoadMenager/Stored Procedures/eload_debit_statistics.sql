CREATE PROCEDURE ELoadMenager.eload_debit_statistics
@op int, @nd1 datetime, @nd2 datetime
as
begin
select u.fio [Оператор], convert(varchar,d.dt,104) [Дата], sum(iif(d.job_type=0,1,0)) [Звонки], sum(iif(d.job_type=6,1,0)) [Отказы], 
			 sum(iif(d.job_type=1,1,0)) [Недозвон], count(distinct p.job_id) [Графики платежей]
from tax.job_detail d
join dbo.usrpwd u on u.uin=d.op
left join tax.payments p on p.job_id=d.job_id
join tax.job_types_list jtl on jtl.id=d.job_type
where d.op=@op and d.dt between @nd1 and @nd2+'23:59:59' and jtl.tech_job=0
group by u.fio, convert(varchar,d.dt,104)
end