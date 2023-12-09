CREATE procedure tax.check_work_close
@work_id int,
@res bit =0 output,
@msg varchar(2500) ='' output,
@op int
as 
begin
	set @res=0
  set @msg=''
  
  set @msg=stuff((
  select N''+'['+convert(varchar,p.nd,104)+']: '+format(p.payment,'C','ru-ru')+' ['+s.list+'];'+char(13) 
  from tax.payments p
  join tax.payment_state_list s on s.id=p.payment_state_id
  where work_id=@work_id and not payment_state_id in (1,2)
  order by p.nd
  for xml path(''), type).value('.','varchar(max)'),1,0,'')
  set @msg=isnull(@msg,'')
  set @res=iif(@msg='',1,0)
  
  if @res=1
  begin
  	declare @fio varchar(200)
    select @fio=fio from dbo.usrpwd where uin=@op
  	insert into tax.work_det (work_id,remark,op) values(@work_id,'закрытие работы по клинету',@op)
    update w set w.work_closed=1, w.dt_end=convert(varchar,getdate(),104), w.op_end=@op, w.op_end_fio=@fio
    from tax.works w    
    where w.work_id=@work_id
  end
end