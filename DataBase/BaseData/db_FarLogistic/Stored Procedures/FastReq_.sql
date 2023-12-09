CREATE PROCEDURE [db_FarLogistic].FastReq_
@uin int,
@casher int,
@cost money,
@pFrom int,
@pTo int,
@dFrom datetime,
@dTo datetime,
@JorneyTypeID int,
@vendorid int, 
@count int,
@weight float,
@basis int,
@DepID int=0
AS
  declare @TranName varchar(8)
  select @TranName = 'FastReq'
  
  BEGIN TRAN @TranName
  declare @st varchar(max) 
  
  declare @IDReq int
  declare @pa1 int
  declare @pa2 int
  
  --костыль, в закупке не так часто обновляют программу
  if @JorneyTypeID=0 
  	set @JorneyTypeID=1
  
  if @JorneyTypeID in (1,2)
  begin
  set @pa1=2
  set @pa2=5
  end
  else
  begin
  set @pa1=7
  set @pa2=8
  end;
   
  insert into dbo.requests(nd, neednd, depidcust, depidexec, status, op, rs, 
													remarkmain, bypass, bycall, itsright, ksoper, rf, 
                          plataover, remarkfin, remarkexec, reqav, period, 
                          plata, nal, remarkmtr, content, otv2, tip2, data2, 
                          resfin2, prior2, remark) 
	values(GETDATE(), @dFrom, 10, 10, 1, @uin, 1, 
				'', 0, 0, 1, 66, 0, 0, '', 
				'', 0, 0, @cost, 0, '', 'Грузоперевозка для'+(select d.brName from def d where d.pin = @vendorid), 
        0, 37, 'Груз', -1, 0, 'Организовать маршрут')
        
  select @IDReq = @@IDENTITY
  
  insert into [db_FarLogistic].dlJorneyInfo (
	    			[db_FarLogistic].dlJorneyInfo.IDReq,
            [db_FarLogistic].dlJorneyInfo.CasherID,
            [db_FarLogistic].dlJorneyInfo.JorneyTypeID,
            [db_FarLogistic].dlJorneyInfo.Cost,
            [db_FarLogistic].dlJorneyInfo.usr,
            [db_FarLogistic].dlJorneyInfo.VendorID,
            [db_FarLogistic].dlJorneyInfo.BasisIDReq,
            [db_FarLogistic].dlJorneyInfo.DepID)
	values (@IDReq, @casher, @JorneyTypeID, @cost, @uin, @vendorid, @basis, @DepID)
  
  insert into [db_FarLogistic].dlJorney (
	   			  [db_FarLogistic].dlJorney.IDReq,
            [db_FarLogistic].dlJorney.Numb,
            [db_FarLogistic].dlJorney.IDdlPointAction,
            [db_FarLogistic].dlJorney.IDdlDelivPoint,
            [db_FarLogistic].dlJorney.Usr,
            [db_FarLogistic].dlJorney.PDate,
            [db_FarLogistic].dlJorney.PCount,
            [db_FarLogistic].dlJorney.PWeight)
	values (@IDReq, 0, @pa1, @pFrom, @uin, @dFrom, @count, @weight)

	insert into [db_FarLogistic].dlJorney (
	    			[db_FarLogistic].dlJorney.IDReq,
            [db_FarLogistic].dlJorney.Numb,
            [db_FarLogistic].dlJorney.IDdlPointAction,
            [db_FarLogistic].dlJorney.IDdlDelivPoint,
            [db_FarLogistic].dlJorney.Usr,
            [db_FarLogistic].dlJorney.PDate,
            [db_FarLogistic].dlJorney.PCount,
            [db_FarLogistic].dlJorney.PWeight)
	values (@IDReq, 1, @pa2, @pTo, @uin, @dTo, @count, @weight)
  
  if @@ERROR = 0 
  COMMIT TRAN @TranName
  ELSE ROLLBACK TRAN @TranName