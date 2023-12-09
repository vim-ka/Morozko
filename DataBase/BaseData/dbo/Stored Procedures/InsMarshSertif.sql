CREATE PROCEDURE dbo.InsMarshSertif
@mhid int, 
@op int,
@brnom varchar(200)='-1'
AS
BEGIN
	declare @tranname varchar(15)
	set @tranname='InsMarshSertif'
	begin tran @tranname
		declare @erReg int
		set @erReg=0
        
        delete from NearLogistic.MarshRequests
        where 	mhID=@mhid
        		and ReqID in (select ms.mvk from MarshSertif ms where ms.mhid=@mhid)		
        if @@error<>0
		set @erReg=@erReg+1
		if @erReg<>0 goto proc_end
        
		delete from MarshSertif where mhid=@mhid
		if @@error<>0
		set @erReg=@erReg+1
		if @erReg<>0 goto proc_end
		
		declare @sql varchar(2000)
		set @sql=''
		set @sql='insert into MarshSertif (Op,mhid,BrNo)'
		set @sql=@sql+' select '+cast(@op as varchar)+','+cast(@mhid as varchar)+', brno'
		set @sql=@sql+' from SertifBranch'
		set @sql=@sql+' where brno in ('+@brnom+')'
		exec(@sql)
		if @@error<>0
		set @erReg=@erReg+2		
        if @erReg<>0 goto proc_end
        
        insert into NearLogistic.MarshRequests (op,mhID,ReqID,ReqType,ReqAction,PINTo)
        select @op,@mhid,ms.Mvk,4,0,sb.BrNo
        from MarshSertif ms
        join SertifBranch sb on ms.BrNo=sb.BrNo
        where ms.mhid=@mhid        
		if @@error<>0
		set @erReg=@erReg+2
		if @erReg<>0 goto proc_end
		
	proc_end:
	declare @msg varchar(50)
	set @msg=''
	if @erReg=0 
	begin
		commit tran @tranname
		select cast(0 as bit) as [res], @msg as [msg]
	end
	else
	begin
		if (@erReg & 1)<>0
		set @msg=@msg+'Ошибка удаления; '
		if (@erReg & 2)<>0
		set @msg=@msg+'Ошибка добавления; '
		
		rollback tran @tranname
		select cast(1 as bit) as [res], @msg as [msg]
	end
END