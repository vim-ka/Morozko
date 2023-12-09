create procedure tax.get_job_detail_list
@job_id int 
as 
begin
	select d.*, t.list [job_type_name], u.fio [op_name]
  from tax.job_detail d
  join tax.job_types_list t on t.id=d.job_type
  join dbo.usrpwd u on u.uin=d.op
  where job_id=@job_id
  order by d.dt desc
end