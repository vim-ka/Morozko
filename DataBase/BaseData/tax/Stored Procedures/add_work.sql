CREATE procedure tax.add_work
@work_id int output,
@dck int,
@op int
as
begin
	if @work_id=-1 
  	set @work_id=isnull((select top 1 work_id from tax.works where dck=@dck and work_closed=0),-1)
	
  if @work_id=-1
  begin
    insert into tax.works (dck,op,op_fio)
    select @dck,@op,u.fio
    from dbo.usrpwd u
    where u.uin=@op
    select @work_id=@@identity
  end
    
  insert into tax.work_det (work_id, op) values(@work_id,@op)
end