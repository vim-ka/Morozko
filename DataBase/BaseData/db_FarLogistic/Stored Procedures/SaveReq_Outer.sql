CREATE PROCEDURE [db_FarLogistic].[SaveReq_Outer]
@IDReq int,
@uin int,
@casher int,
@cost money,
@pFrom int,
@pTo int,
@dFrom datetime,
@dTo datetime,
@isComerce bit,
@vendorid int, 
@count int,
@weight float,
@basis int
AS
  declare @TranName varchar(8)
  select @TranName = 'SaveReq_Outer'
  
  BEGIN TRAN @TranName
  declare @st varchar(max)
  
  insert into [db_FarLogistic].dlJorneyInfo (
	    			[db_FarLogistic].dlJorneyInfo.IDReq,
            [db_FarLogistic].dlJorneyInfo.CasherID,
            [db_FarLogistic].dlJorneyInfo.isCommerce,
            [db_FarLogistic].dlJorneyInfo.Cost,
            [db_FarLogistic].dlJorneyInfo.usr,
            [db_FarLogistic].dlJorneyInfo.VendorID,
            [db_FarLogistic].dlJorneyInfo.BasisIDReq)
	values (@IDReq, @casher, @isComerce, @cost, @uin, @vendorid, @basis)
  
  insert into [db_FarLogistic].dlJorney (
	   			  [db_FarLogistic].dlJorney.IDReq,
            [db_FarLogistic].dlJorney.Numb,
            [db_FarLogistic].dlJorney.IDdlPointAction,
            [db_FarLogistic].dlJorney.IDdlDelivPoint,
            [db_FarLogistic].dlJorney.Usr,
            [db_FarLogistic].dlJorney.PDate,
            [db_FarLogistic].dlJorney.PCount,
            [db_FarLogistic].dlJorney.PWeight)
	values (@IDReq, 0, 2, @pFrom, @uin, @dFrom, @count, @weight)

	insert into [db_FarLogistic].dlJorney (
	    			[db_FarLogistic].dlJorney.IDReq,
            [db_FarLogistic].dlJorney.Numb,
            [db_FarLogistic].dlJorney.IDdlPointAction,
            [db_FarLogistic].dlJorney.IDdlDelivPoint,
            [db_FarLogistic].dlJorney.Usr,
            [db_FarLogistic].dlJorney.PDate,
            [db_FarLogistic].dlJorney.PCount,
            [db_FarLogistic].dlJorney.PWeight)
	values (@IDReq, 1, 5, @pTo, @uin, @dTo, @count, @weight)
  
  if @@ERROR = 0 
  COMMIT TRAN @TranName
  ELSE ROLLBACK TRAN @TranName