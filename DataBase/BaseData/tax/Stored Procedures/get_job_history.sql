CREATE procedure tax.get_job_history
@job_id int
as 
begin
	declare @pin int, @issingle bit
  select @pin=pin, @issingle=issingle
  from tax.job where job_id=@job_id

  select j.job_id [id], iif(exists(select 1 from tax.job_detail a where a.job_id=j.job_id and d.job_type=3),'[закрыта]','')+'['+convert(varchar,d.dt,104)+'] '+u.fio [list]
  from tax.job j
  join tax.job_detail d on d.job_id=j.job_id and d.job_type=2
  join dbo.usrpwd u on u.uin=d.op
  where pin=@pin and issingle=@issingle
  order by d.dt desc
end