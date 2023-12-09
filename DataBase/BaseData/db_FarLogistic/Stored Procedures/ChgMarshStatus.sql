CREATE PROCEDURE db_FarLogistic.ChgMarshStatus
@MarshID int,
@uin int,
@StatusID int,
@dt datetime,
@odo int
AS
update db_FarLogistic.dlMarsh 
	 set 	IDdlMarshStatus=@StatusID,
	 			dt_beg_fact=case when @StatusID=2 then @dt else dt_beg_fact end,
				dt_end_fact=case when @StatusID=2 then dt_end_fact else @dt end,
				odo_beg_fact=case when @StatusID=2 then @odo else odo_beg_fact end,
				odo_end_fact=case when @StatusID=2 then odo_end_fact else @odo end,
				IDUsrPwd=@uin
where dlMarshID=@MarshID

update Requests 
		set Rs=case when @StatusID=2 then 5 else 6 end, 
				RemarkExec='Маршрут №'+cast(@MarshID as varchar)+(case when @StatusID=2 then 'отправлен от ' else 'завершен ' end)+cast(@dt as varchar)+'{'+cast(getdate() as varchar)+'}' 
where rk in (select IDReq from db_FarLogistic.dlJorneyInfo where MarshID=@MarshID)