CREATE PROCEDURE db_FarLogistic.RollbackBill
@BillID int,
@is1C bit=0
AS
BEGIN
	declare @tranname varchar(12)
	set @tranname='RollbackBill'
	begin tran @tranname
	declare @erReg int
	declare @msg varchar(500)
	set @msg=''
	set @erReg=0
  if not exists(select * from db_FarLogistic.dlMarsh m where m.dlMarshID=@BillID/100)
	begin
		set @erReg=@erReg+4
		if @erReg<>0
		goto end_procedure
	end
	
	if exists(select * from db_FarLogistic.dlgroupbill b where b.MarshID=@BillID/100 and b.UnLoaded=1)
	begin
		if @is1C=0
		set @erReg=@erReg+1
		if @erReg<>0
		goto end_procedure
	end
	
	delete from db_FarLogistic.dlGroupBill where MarshID=@BillID/100
	if @@error<>0
	set @erReg=@erReg+2
	if @erReg<>0
	goto end_procedure
	
	end_procedure:
	if @erReg=0
	begin
		commit tran @tranname
		select cast(0 as bit) [res], @msg [msg]
	end
	else
	begin
		if (@erReg & 1)<>0
		set @msg=@msg+'C данным счетом связан выгруженный счет откат не возможен; '
		if (@erReg & 2)<>0
		set @msg=@msg+'Ошибка при удалении, откат не произведен; '
		if (@erReg & 4)<>0
		set @msg=@msg+'Данный счет возможно откатить через старое ПО; '
		commit tran @tranname
		select cast(1 as bit) [res], @msg [msg]
	end
END