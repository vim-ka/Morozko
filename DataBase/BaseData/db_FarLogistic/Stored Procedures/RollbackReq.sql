CREATE PROCEDURE db_FarLogistic.RollbackReq
@IDReq int
AS
	update db_FarLogistic.dlJorneyInfo set MarshID=-1 where IDReq=@IDReq
	update Requests set Rs=1, RemarkExec='Выведена из маршрута {'+cast(getdate() as varchar)+'}' where rk=@IDReq