CREATE PROCEDURE [db_FarLogistic].AddReqMaster
@Reqs ntext,
@Usr int,
@casher int
AS
BEGIN --Процедура пока работает только для морозко, для остальных придется менять точку выгрузки
  declare @TranName varchar(10)
  select @TranName = 'MasterReq'
  
  BEGIN TRAN @TranName
  
  declare @PointAction int
  declare @PointID int 
  declare @Count int
  declare @Weight float
  declare @Date datetime
  declare @First int
  declare @NewIDReq int
  declare @SumCount int
  declare @SumWeight float
  declare @LastDate datetime
  
  set @First=0
  set @SumCount=0
  set @SumWeight=0
  
  declare cur_jor cursor for 
  select j.IDdlPointAction, j.IDdlDelivPoint, j.PCount, j.PWeight, j.PDate 
  from db_FarLogistic.dlJorney j 
  where j.IDReq in (select * from db_FarLogistic.String_to_Int(@Reqs)) and j.IDdlPointAction in (2,3,4)
  order by j.IDReq  
  
  open cur_jor
  
  insert into dbo.requests(nd, neednd, depidcust, depidexec, status, op, rs, 
													remarkmain, bypass, bycall, itsright, ksoper, rf, 
                          plataover, remarkfin, remarkexec, reqav, period, 
                          plata, nal, remarkmtr, content, otv2, tip2, data2, 
                          resfin2, prior2, remark) 
	values(GETDATE(), @Date, 10, 10, 1, @Usr, 1, 
				'', 0, 0, 1, 66, 0, 0, '', 
				'', 0, 0, 0, 0, '', 'Объединение заявок', 
        0, 37, 'Груз', -1, 0, 'Организовать маршрут')
        
  select @NewIDReq = @@IDENTITY
  
  insert into [db_FarLogistic].dlJorneyInfo (
	    			[db_FarLogistic].dlJorneyInfo.IDReq,
            [db_FarLogistic].dlJorneyInfo.CasherID,
            [db_FarLogistic].dlJorneyInfo.JorneyTypeID,
            [db_FarLogistic].dlJorneyInfo.Cost,
            [db_FarLogistic].dlJorneyInfo.usr,
            [db_FarLogistic].dlJorneyInfo.VendorID,
            [db_FarLogistic].dlJorneyInfo.BasisIDReq,
            [db_FarLogistic].dlJorneyInfo.IDReqMaster)
	values (@NewIDReq, @casher, 1, 0, @Usr, -1, -1, -2)
  
  update db_FarLogistic.dlJorneyInfo set IDReqMaster=@NewIDReq where IDReq in (select * from db_FarLogistic.String_to_Int(@Reqs))
  
  fetch next from cur_jor into
  @PointAction, @PointID, @Count, @Weight, @Date
  
  while @@FETCH_STATUS=0 
  begin
  	if @First=0 
    begin 
    	insert into [db_FarLogistic].dlJorney (
	   			  [db_FarLogistic].dlJorney.IDReq,
            [db_FarLogistic].dlJorney.Numb,
            [db_FarLogistic].dlJorney.IDdlPointAction,
            [db_FarLogistic].dlJorney.IDdlDelivPoint,
            [db_FarLogistic].dlJorney.Usr,
            [db_FarLogistic].dlJorney.PDate,
            [db_FarLogistic].dlJorney.PCount,
            [db_FarLogistic].dlJorney.PWeight)
			values (@NewIDReq, 0, 2, @PointID, @Usr, @Date, @count, @weight)
    end
    else
    begin
    	if @PointAction=2 
      begin
      	insert into [db_FarLogistic].dlJorney (
	   			  [db_FarLogistic].dlJorney.IDReq,
            [db_FarLogistic].dlJorney.Numb,
            [db_FarLogistic].dlJorney.IDdlPointAction,
            [db_FarLogistic].dlJorney.IDdlDelivPoint,
            [db_FarLogistic].dlJorney.Usr,
            [db_FarLogistic].dlJorney.PDate,
            [db_FarLogistic].dlJorney.PCount,
            [db_FarLogistic].dlJorney.PWeight)
				values (@NewIDReq, @First, 3, @PointID, @Usr, @Date, @count, @weight)
      end
      else
      begin
      	insert into [db_FarLogistic].dlJorney (
	   			  [db_FarLogistic].dlJorney.IDReq,
            [db_FarLogistic].dlJorney.Numb,
            [db_FarLogistic].dlJorney.IDdlPointAction,
            [db_FarLogistic].dlJorney.IDdlDelivPoint,
            [db_FarLogistic].dlJorney.Usr,
            [db_FarLogistic].dlJorney.PDate,
            [db_FarLogistic].dlJorney.PCount,
            [db_FarLogistic].dlJorney.PWeight)
				values (@NewIDReq, @First, @PointAction, @PointID, @Usr, @Date, @count, @weight)
      end
    end
    
    if @PointAction in (2,3)
    begin
    	set @SumCount=@SumCount+@count
      set @SumWeight=@SumWeight+@weight
    end
    else
    begin
    	set @SumCount=@SumCount-@count
      set @SumWeight=@SumWeight-@weight
    end
    
    set @LastDate=@Date
    
    set @First=@First+1
    fetch next from cur_jor into
  	@PointAction, @PointID, @Count, @Weight, @Date
  end 
  
  insert into [db_FarLogistic].dlJorney (
	   			  [db_FarLogistic].dlJorney.IDReq,
            [db_FarLogistic].dlJorney.Numb,
            [db_FarLogistic].dlJorney.IDdlPointAction,
            [db_FarLogistic].dlJorney.IDdlDelivPoint,
            [db_FarLogistic].dlJorney.Usr,
            [db_FarLogistic].dlJorney.PDate,
            [db_FarLogistic].dlJorney.PCount,
            [db_FarLogistic].dlJorney.PWeight)
	values (@NewIDReq, @First, 5, 8, @Usr, @LastDate, @SumCount, @SumWeight)
  
  close cur_jor
  deallocate cur_jor
  
  if @@ERROR = 0 
  COMMIT TRAN @TranName
  ELSE ROLLBACK TRAN @TranName
END