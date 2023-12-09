CREATE PROCEDURE db_FarLogistic.NewCostMarsh
@MarshID int,
@WorkID int 
AS
declare @tranname varchar(12)
set @tranname='NewCostMarsh'
begin tran @tranname 
	declare @erReg int
	set @erReg=0
	
	declare @PalCount int
	declare @KM int
	declare @NewCost money
	declare @MinCost money
	declare @DotCost money
	declare @ReqCost money
	declare @KMPalCost money
	declare @DotsCount int
	declare @MinKM int
	declare @VehType int
	
	if @WorkID<>0
	begin	
		select @ReqCost=sum(ji.Cost)
		from db_FarLogistic.dlJorneyInfo ji
		where ji.IDReq in (select j.IDReq 
											 from db_FarLogistic.dlJorney j 
											 where j.NumberWorks=@WorkID) and 
											 			 ji.MarshID=@MarshID
		set @erReg=@erReg+@@error 
		
		if @ReqCost=0
		begin
			select @VehType=v.dlVehTypeID
			from db_FarLogistic.dlVehicles v 
			where v.dlVehiclesID=(select m.IDdlVehicles 
														from db_FarLogistic.dlMarsh m 
														where m.dlMarshID=@MarshID)
			set @erReg=@erReg+@@error
			
			select top 1 @DotCost=e.DotCost, 
									 @KMPalCost=e.KMPalCost, 
									 @MinKM=e.MinRaceKM, 
									 @MinCost=e.MinCost
			from db_FarLogistic.dlExpence e
			where e.IDVehTYpe=@VehType and 
						e.DateStart<=cast(getdate() as date) 
			order by e.DateStart desc 
			set @erReg=@erReg+@@error
			 
			select @PalCount=sum(isnull(j.FCount,j.PCount))
			from db_FarLogistic.dlJorney j
			join db_FarLogistic.dlJorneyInfo ji on ji.IDReq=j.IDReq
			where ji.MarshID=@MarshID and 
						j.NumberWorks=@WorkID and 
						j.IDdlPointAction in (2,3) and 
						j.NumbForRace<>-1
			set @erReg=@erReg+@@error
			
			select @DotsCount=count(j.IDReq)
			from db_FarLogistic.dlJorney j
			join db_FarLogistic.dlJorneyInfo ji on ji.IDReq=j.IDReq
			where ji.MarshID=@MarshID and 
						j.NumberWorks=@WorkID and 
						j.NumbForRace<>-1
			set @erReg=@erReg+@@error
			
			select @KM=c.KM
			from db_FarLogistic.dlTmpMarshCost c
			where c.MarshID=@MarshID and 
						c.WorkID=@WorkID
			set @erReg=@erReg+@@error
			
			if @MinKM>=@KM
			begin
				set @NewCost=@MinCost
				set @erReg=@erReg+@@error
			end
			else
			begin
				set @NewCost=@KM*@PalCount*@KMPalCost+(@DotsCount-2)*@DotCost
				set @erReg=@erReg+@@error
			end
		end
		else
		begin
			set @NewCost=@ReqCost
			set @erReg=@erReg+@@error
			set @DotsCount=-1
			set @erReg=@erReg+@@error
			set @PalCount=-1
			set @erReg=@erReg+@@error
		end
	end
	else
	begin
		select @NewCost=t.Cost, @DotsCount=0, @PalCount=0
		from db_FarLogistic.dlTmpMarshCost t
		where t.MarshID=@MarshID and t.WorkID=@WorkID
		set @erReg=@erReg+@@error
	end
	
	print @KM
	print @MinKM
		
	update db_FarLogistic.dlTmpMarshCost set
		NewCost=@NewCost,
		DotsCount=@DotsCount,
		PalCount=@PalCount 
	where MarshID=@MarshID and WorkID=@WorkID
	
	set @erReg=@erReg+@@error
	
if @erReg=0 
begin
	commit tran @tranname
	select cast(0 as bit) res, '' msg
end
else
begin
	rollback tran @tranname
	select cast(1 as bit) res, 'При рассчете произошла ошибка, попробуйте позднее' msg
end