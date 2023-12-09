CREATE PROCEDURE db_FarLogistic.FastReqHeader
@casherID int,
@venderID int,
@cost money, 
@jorneytypeID int,
@uin int
AS
	declare @IDReq int 
	insert into dbo.requests(nd, neednd, depidcust, depidexec, status, op, rs, 
													remarkmain, bypass, bycall, itsright, ksoper, rf, 
                          plataover, remarkfin, remarkexec, reqav, period, 
                          plata, nal, remarkmtr, content, otv2, tip2, data2, 
                          resfin2, prior2, remark) 
	values(GETDATE(), getdate(), 10, 10, 1, @uin, 1, 
				'', 0, 0, 1, 66, 0, 0, '', 
				'', 0, 0, @cost, 0, '', 'Грузоперевозка для'+(select d.brName from def d where d.pin = @casherID), 
        0, 37, 'Груз', -1, 0, 'Организовать маршрут')
        
  select @IDReq = @@IDENTITY
  
  insert into [db_FarLogistic].dlJorneyInfo (
	    			[db_FarLogistic].dlJorneyInfo.IDReq,
            [db_FarLogistic].dlJorneyInfo.CasherID,
            [db_FarLogistic].dlJorneyInfo.JorneyTypeID,
            [db_FarLogistic].dlJorneyInfo.Cost,
            [db_FarLogistic].dlJorneyInfo.usr,
            [db_FarLogistic].dlJorneyInfo.VendorID,
            [db_FarLogistic].dlJorneyInfo.BasisIDReq)
	values (@IDReq, @casherID, @JorneyTypeID, @cost, @uin, @venderid, -1)
	
	select @IDReq [IDReq]