CREATE PROCEDURE ArrivalBuh.DeleteComman
@ncom int
AS
BEGIN
  declare @tran varchar(15)
  set @tran='DeleteComman'
  begin tran @tran
  declare @ErrReg int
  set @ErrReg=0
  
  delete from Inpdet where ncom=@ncom
  set @ErrReg=@ErrReg+@@error
	
  delete from Comman where ncom=@ncom
  set @ErrReg=@ErrReg+@@error
 
  delete from tdvi where ncom=@ncom
  set @ErrReg=@ErrReg+@@error
	
  --delete izmen where ncom=@ncom
  --set @ErrReg=@ErrReg+@@error
	
  update PrihodReq set PrihodRDone=10, PrihodRSaveTo=1
  where PrihodRID=(select top 1 PrihodRID from PrihodReqDet where PrihodRDetncom=@ncom)
  set @ErrReg=@ErrReg+@@error

  update PrihodReqDet set PrihodRDetIsSave=0 where PrihodRDetncom=@ncom
  set @ErrReg=@ErrReg+@@error
    
  if @ErrReg=0
  	commit tran @tran
  else
  	rollback tran @tran
    
  select cast(iif(@ErrReg<>0,1,0) as bit) [res],
  		 iif(@ErrReg<>0,'Во время удаления произошли ошибки, попоробуйте снова позже','') [msg]  
END