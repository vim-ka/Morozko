CREATE PROCEDURE dbo.RestoreCostAndPrice
@PrihodRID int,
@isPrice bit
AS
declare @erReg int
declare @tranname varchar(19)
set @tranname='RestoreCostAndPrice'
begin tran @tranname
	set @erReg=0
	declare @dck int
	select @dck=PrihodRDefContract
	from PrihodReq 
	where PrihodRID=@PrihodRID
	
	declare @hitag int
	declare @curID int
	declare @RestoreSum float 
	
	declare curDet cursor for
	select PrihodRDetID, PrihodRDetHitag
	from PrihodReqDet
	where PrihodRID=@PrihodRID
	
	open curDet 
	fetch next from curDet into @curID, @hitag
	
	while @@fetch_status=0 
	begin
		set @RestoreSum=-1
		if exists(select * from NomenVend where hitag=@hitag and dck=@dck)
			if @isPrice=0 
			begin
				select @RestoreSum=nv.cost from NomenVend nv where nv.Hitag=@hitag and nv.DCK=@dck
				update PrihodReqDet set PrihodRDetCost=@RestoreSum
				where PrihodRDetID=@curID
				set @erReg=@erReg+@@error
			end
			else
			begin
				select @RestoreSum=nv.price from NomenVend nv where nv.Hitag=@hitag and nv.DCK=@dck
				update PrihodReqDet set PrihodRDetPrice=@RestoreSum
				where PrihodRDetID=@curID
				set @erReg=@erReg+@@error
			end
		fetch next from curDet into @curID, @hitag
	end
	
	close curDet
	deallocate curDet 
	
if @erReg=0
begin
	commit tran @tranname
	update PrihodReq set NeedReCalc=1 where PrihodRID=@PrihodRID
	select cast(0 as bit) [res], '' [msg]
end
else
begin
	commit tran @tranname 
	select cast(1 as bit) [res], 'Во время выполнения произошли ошибки' [msg]
end