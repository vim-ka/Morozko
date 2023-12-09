CREATE PROCEDURE db_FarLogistic.CancelReq
@IDReq int
AS
if exists(select * from db_FarLogistic.dlJorneyInfo where IDReq=@IDReq and isnull(BasisIDReq,-1)=-1)
begin
	delete from db_FarLogistic.dlJorneyInfo where IDReq=@IDReq
	delete from db_FarLogistic.dlJorney where IDReq=@IDReq
	delete from Requests where Rk=@IDReq
end
else
begin
	update db_FarLogistic.dlJorneyInfo set isCancel=1, ComentCancel=cast(getdate() as varchar) where IDReq=@IDReq
	update Requests set Rs=7, RemarkExec='Отменена оператором логистики '+cast(getdate() as varchar) where rk=@IDReq
end