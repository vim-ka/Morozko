CREATE PROCEDURE db_FarLogistic.AppendReqInMarsh
@MarshID int,
@IDReq int
AS
	update db_FarLogistic.dlJorneyInfo set MarshID=@MarshID where IDReq=@IDReq
	update Requests set Rs=2, RemarkExec='Помещена в маршрут №'+cast(@MarshID as varchar)+'{'+cast(getdate() as varchar)+'}' where rk=@IDReq