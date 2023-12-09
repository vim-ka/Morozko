CREATE PROCEDURE NearLogistic.ListPayDel
@listno int
AS
BEGIN
  declare @tranname varchar(10)
  set @tranname='ListPayDel'
  begin tran @tranname
  declare @max_listno int
  declare @additional int
  declare @isSped bit
  declare @res int
  declare @msg varchar(5000)
  set @res=0
  set @msg=''
  
  select @max_listno=max(listno) from NearLogistic.nlListPay
  if @max_listno>@listno set @res=@res+1
  
  select top 1 @additional=AdditionalHeaderID from NearLogistic.nlListPay where ListNo=@listno
  if @additional<>0 set @res=@res+2    
  
  select @isSped=iif(ttid=5,1,0)
  from NearLogistic.nlListPay
  where ListNo=@listno
  
  delete from NearLogistic.nlListPayDet where ListNo=@listno
  set @res=@res+iif(@@error<>0,8,0)
  
  delete from NearLogistic.nlListPay where listno=@listno
  set @res=@res+iif(@@error<>0,4,0)
  
  alter table dbo.Marsh disable trigger trg_Marsh_u
  update m set m.ListNo=iif(@isSped=1,m.ListNo,0),
         m.ListNoSped=iif(@isSped=1,0,m.ListNoSped),
               m.MStatus=3
  from dbo.marsh m
  where m.ListNo=iif(@isSped=1,m.ListNo,@listno)
     and m.ListNoSped=iif(@isSped=1,@listno,m.ListNoSped)
  set @res=@res+iif(@@error<>0,16,0)
  --alter table dbo.Marsh enable trigger trg_Marsh_u
  
  
  if @res & 1<>0 set @msg=@msg+'Удалить возможно только последнюю ведомость!'
  if @res & 2<>0 set @msg=@msg+'Ведомость выгружена в зарплатную ведомость!'
  if @res & 4<>0 set @msg=@msg+'Ошибка удаления! Попробуйте снова позже'
  if @res & 8<>0 set @msg=@msg+'Ошибка удаления! Попробуйте снова позже'
  if @res & 16<>0 set @msg=@msg+'Ошибка удаления! Попробуйте снова позже'
  
  if @res=0  
  begin
   select cast(0 as bit) [res], @msg [msg]
    commit tran @tranname
  end
  else
  begin
   select cast(1 as bit) [res], @msg [msg]
    rollback tran @tranname
  end
END