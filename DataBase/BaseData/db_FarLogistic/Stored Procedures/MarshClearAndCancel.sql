CREATE PROCEDURE db_FarLogistic.MarshClearAndCancel
@MarshID int
AS
	update db_FarLogistic.dlJorneyInfo set MarshID=-1 where MarshID=@MarshID
	update Requests set Rs=1, RemarkExec='Выведена из маршрута №'+cast(@MarshID as varchar)+'{'+cast(getdate() as varchar)+'}' where rk in (select IDReq from db_FarLogistic.dlJorneyInfo where MarshID=@MarshID)
	update db_FarLogistic.dlMarsh set IDdlMarshStatus=5 where dlMarshID=@MarshID