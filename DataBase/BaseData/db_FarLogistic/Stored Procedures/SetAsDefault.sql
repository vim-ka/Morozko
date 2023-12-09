CREATE PROCEDURE db_FarLogistic.SetAsDefault
@IDMarsh int
AS
	declare @TranName varchar(12)
  select @TranName = 'SetAsDefault'
  
  BEGIN TRAN @TranName
  
  update db_FarLogistic.dlJorney set
  db_FarLogistic.dlJorney.FCount=db_FarLogistic.dlJorney.PCount, 
  db_FarLogistic.dlJorney.FDate=db_FarLogistic.dlJorney.PDate,
  db_FarLogistic.dlJorney.FWeight=db_FarLogistic.dlJorney.PWeight
  where db_FarLogistic.dlJorney.IDReq in (select ji.idreq from db_FarLogistic.dlJorneyInfo ji where ji.MarshID=@IDMarsh) 
  
  if @@ERROR = 0 
  COMMIT TRAN @TranName
  ELSE ROLLBACK TRAN @TranName