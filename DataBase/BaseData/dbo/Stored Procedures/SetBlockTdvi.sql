CREATE PROCEDURE dbo.SetBlockTdvi
@id int,
@locked bit,
@lockid int,
@op int,
@com varchar(20)
AS
BEGIN
  declare @tranname varchar(12)
	set @tranname='SetBlockTdvi'
	begin tran @tranname
	declare @erReg int
	set @erReg=0
	
	declare @hitag int 
	declare @rest int 
	
	select 	@hitag=t.hitag,
					@rest=t.morn-t.sell+t.isprav-t.remov
	from tdvi t
	where t.id=@id
	if @@error<>0
		set @erReg=@erReg+1
	
	if @erReg=0
	begin
		update tdvi set locked=@locked,
										lockid=case when @locked=0 then 0 else @lockid end
		where id=@id
		if @@error<>0
			set @erReg=@erReg+2
	end
	
	if @erReg=0
	begin
		insert into [log] (op, tip, mess, Remark, Param1, Param2, Param3, Param4)
		values (@op,
						case when @locked=1 then 'Блок' else 'Блок-' end,
						case when @locked=1 then 'Блокировка, Hitag/ID/Rest:' else 'Разблокировка, Hitag/ID/Rest:' end,
						@com,
						cast(@hitag as varchar),
						cast(@id as varchar),
						cast(@rest as varchar),
						null
						)
		if @@error<>0
			set @erReg=@erReg+4
	end
	
	if @erReg=0
	begin
		commit tran @tranname
		select cast(0 as bit) [res], cast('' as varchar(50)) [msg] 
	end
	else
	begin
		rollback tran @tranname
		select cast(1 as bit) [res], cast('Ошибка при выполнении:'+cast(@erReg as varchar) as varchar(50)) [msg]
	end
END