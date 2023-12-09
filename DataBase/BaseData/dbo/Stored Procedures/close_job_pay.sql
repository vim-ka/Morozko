CREATE procedure dbo.close_job_pay
@addid int,
@persid int,
@sm money
as
begin
declare @tran varchar(50), @msg varchar(500), @erreg int, @comp varchar(100), @comp_ varchar(100)
set @erreg=0; set @msg=''; set @tran='AdditionalUpdateFromKassa'; set @comp=host_name()
begin tran @tran
if not exists(select 1 from dbo.kassalock where persid=@persid and comp<>@comp)
begin
  if not exists(select 1 from hrmain.dbo.additional where persid=@persid and additionalheaderid=@addid)
  begin
    if not exists(select 1 from hrmain.dbo.additional where persid=@persid and additionalheaderid=@addid and additionaltypeid=999 and [sum]=0)  
    begin
      update a set a.[sum]=@sm, a.additionalremark=cast(getdate() as varchar)+' ['+@comp+']'
      from hrmain.dbo.additional a
      where a.persid=@persid and a.additionalheaderid=@addid and a.additionaltypeid=999
      if @@error<>0 set @erreg=4
    end
    else set @erreg=2
  end
  else set @erreg=1
end
else 
begin
	set @erreg=8
  set @comp_=(select top 1 comp from dbo.kassalock where persid=@persid order by dt desc)
end
if (@erreg & 1)<>0 set @msg=@msg+'Начисления для данного сотрудника нет в выбранной ведомости';
if (@erreg & 2)<>0 set @msg=@msg+'Начисления уже произведены';
if (@erreg & 4)<>0 set @msg=@msg+'Ошибка при записи начисления';
if (@erreg & 8)<>0 set @msg=@msg+'Начисление заблокированы оператором '+@comp_;
if @@trancount>0 and @erreg=0 commit tran @tran 
else rollback tran @tran
select cast(iif(@erreg=0,0,1) as bit) [res], @msg [msg]
END