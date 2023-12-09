CREATE PROCEDURE db_FarLogistic.NewReq
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
				'', 0, 0, 0, 0, '', 'Заявка на грузоперевозка', 
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
	values (@IDReq, -1, -1, 0, @uin, -1, -1)
	
	select @IDReq [IDReq]