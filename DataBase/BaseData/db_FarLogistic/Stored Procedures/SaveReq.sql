CREATE PROCEDURE [db_FarLogistic].[SaveReq]
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
@basis int
AS
  declare @TranName varchar(8)
  select @TranName = 'SaveReq'
  
  BEGIN TRAN @TranName
  
  declare @IDReq int 
  declare @pa1 int
  declare @pa2 int
  
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
  
  select @IDReq=isnull(min(ji.IDReq),0)-1
  from db_FarLogistic.dlJorneyInfo ji
  where ji.IDReq<0
  
  insert into [db_FarLogistic].dlJorneyInfo (
	    			[db_FarLogistic].dlJorneyInfo.IDReq,
            [db_FarLogistic].dlJorneyInfo.CasherID,
            [db_FarLogistic].dlJorneyInfo.JorneyTypeID,
            [db_FarLogistic].dlJorneyInfo.Cost,
            [db_FarLogistic].dlJorneyInfo.usr,
            [db_FarLogistic].dlJorneyInfo.VendorID,
            [db_FarLogistic].dlJorneyInfo.BasisIDReq)
	values (@IDReq, @casher, @JorneyTypeID, @cost, @uin, @vendorid, @basis)
  
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