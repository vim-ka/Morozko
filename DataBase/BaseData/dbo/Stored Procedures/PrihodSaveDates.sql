CREATE PROCEDURE dbo.PrihodSaveDates 
@PrihodRID int,
@OP int
AS
declare @tranname varchar(15)
set @tranname='PrihodSaveDates'
begin tran @tranname
declare @erReg int  
set @erReg=0
	
	update nomen set 	ShelfLifeAdd=d.PrihodRDetShelfLifeAdd, 
										ShelfLife=d.PrihodRDetShelfLife 
	from PrihodReqDet d 
	where  	d.PrihodRID=@PrihodRID and 
					d.PrihodRDetHitag=hitag
	set @erReg=@erReg+@@error
	
	update Comman set PrihodDate=getdate() ,
										PrihodOp=@OP 
	where ncom=(select top 1 a.PrihodRDetNCom 
							from PrihodReqDet a 
							where a.PrihodRID=@PrihodRID) 
	set @erReg=@erReg+@@error
	
	update PrihodReq set PrihodROpSave=1 
	where PrihodRID=@PrihodRID
	set @erReg=@erReg+@@error
	
	update inpdet set DATER=d.PrihodRDetDate, 
										SROKH=d.PrihodRDetSrokh 
	FROM PrihodReqDet d 
	where  	d.PrihodRDetNCom=ncom and 
					d.PrihodRID=@PrihodRID and 
					D.PrihodRDetHitag=hitag
	set @erReg=@erReg+@@error
	
	update tdvi set DATER=d.PrihodRDetDate, 
									SROKH=d.PrihodRDetSrokh 
									--LockID=0
												 --(case when (d.PrihodRDetShelfLife>0) and (PrihodRDetDate is not null) then 
												 --		case when DATEDIFF(day,PrihodRDetDate,getdate())*100/d.PrihodRDetShelfLife>v.PercExpDate
												 --		then 3 else 0  end else 0 end) 
	from PrihodReqDet d 
	left join PrihodReq a on d.PrihodRID=a.PrihodRID 
	left join Vendors v on v.Ncod=a.PrihodRVendersID 
	where   d.PrihodRDetNCom=ncom and 
					D.PrihodRID=@PrihodRID and 
					D.PrihodRDetHitag=hitag
	set @erReg=@erReg+@@error
	
	/*update tdvi set LOCKED=(case when LockID=0 then 0 else 1 end) 
	where ncom=(select top 1 a.PrihodRDetNCom 
							from PrihodReqDet a 
							where a.PrihodRID=@PrihodRID)
	set @erReg=@erReg+@@error */
	
	declare @hitag int
	declare @lock int
	declare @kol varchar(10)
	declare cur cursor for
	select  d.PrihodRDetHitag,
					d.PrihodRDetKolStr,
					0
					--case when (d.PrihodRDetShelfLife>0) and (d.PrihodRDetDate is not null) then
					--case when  DATEDIFF(day,d.PrihodRDetDate,getdate())*100/d.PrihodRDetShelfLife<v.PercExpDate then 0 else 3  end 
					--else 3 end
	from PrihodReqDet D 
	left join PrihodReq a on d.PrihodRID=a.PrihodRID
	left join Vendors v on v.Ncod=a.PrihodRVendersID
	left join tdvi t on t.HITAG=d.PrihodRDetHitag and d.PrihodRDetNCom=t.NCOM
	where  	d.PrihodRDetCloneMain=1 and
					d.PrihodRID=@PrihodRID and 
					not d.PrihodRDetHitag in (5659,2296,90858,95007,15028)
					
	open cur
	fetch next from cur into @hitag, @kol, @lock
	
	while @@fetch_status=0 
	begin
		insert into Log (OP,Comp,Tip,MESS,Param1,Param2,Param3,Param4) 
		select 	@OP,
						host_name(),
						case when @lock=0 then 'Блок-' else 'Блок' end,
						case when @lock=0 then 'Разблокировка, Hitag/ID/Rest/Lock:' else 'Блокировка, Hitag/ID/Rest/Lock:' end,
						cast(@hitag as varchar(10)),
						cast(@op as varchar(10)),
						@kol,
						cast(@lock as varchar(2))
		set @erReg=@erReg+@@error		
		
		fetch next from cur into @hitag, @kol, @lock
	end
	
	close cur
	deallocate cur 
	
	
if @erReg=0 
begin
	commit tran @tranname
	select cast(0 as bit) [res], cast('' as varchar(50)) [msg]
end
else
begin
	commit tran @tranname
	select cast(1 as bit) [res], cast('Во время выполнения произошла ошибка, проверьте данные и повторите.' as varchar(50)) [msg]
end