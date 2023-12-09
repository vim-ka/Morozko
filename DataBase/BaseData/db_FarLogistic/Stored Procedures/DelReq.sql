CREATE PROCEDURE [db_FarLogistic].DelReq
@IDReq int,
@Com varchar(max)=NULL
AS
	declare @TranName varchar(8)
  select @TranName = 'DelReq'
  
  BEGIN TRAN @TranName
  
  if @IDReq<0
  begin  	
		delete from db_FarLogistic.dlJorneyInfo 
		where db_FarLogistic.dlJorneyInfo.IDReq = @IDReq
		
    delete from db_FarLogistic.dlJorney 
		where db_FarLogistic.dlJorney.IDReq = @IDReq
		
    delete from Requests 
		where Requests.Rk = @IDReq
  end 
  else
  begin
  	update db_FarLogistic.dlJorneyInfo set
    db_FarLogistic.dlJorneyInfo.isCancel=1,
    db_FarLogistic.dlJorneyInfo.ComentCancel=@com
    where db_FarLogistic.dlJorneyInfo.IDReq=@IDReq
    
    update requests set
    requests.rs=7,
    requests.RemarkExec=@com
    where requests.rk=@IDReq 
  end  
  
  if @@ERROR = 0 
  COMMIT TRAN @TranName
  ELSE ROLLBACK TRAN @TranName