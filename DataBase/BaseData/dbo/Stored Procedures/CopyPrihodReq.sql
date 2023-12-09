CREATE PROCEDURE dbo.CopyPrihodReq
@PrihodRID int,
@OP int,
@only_header bit =1
AS
declare @tranname varchar(13)
set @tranname='CopyPrihodReq'
begin tran @tranname
	declare @NewPrihodRID int
  insert into dbo.PrihodReq (	PrihodRDate, PrihodROperatorID,  PrihodRVendersID, PrihodRDone, PrihodROurID, PrihodRDocNum, PrihodRDocDate, PrihodRComp,
                              PrihodROrdersID, PrihodRTNNum, PrihodRTNDate, PrihodRDefContract, PrihodRDefSafeCust, PrihodRVenderPin ) 
  select convert(varchar,getdate(),4), @OP, PrihodRVendersID, 0, PrihodROurID, PrihodRDocNum, PrihodRDocDate, host_name(), PrihodROrdersID,
                              PrihodRTNNum, PrihodRTNDate, PrihodRDefContract, PrihodRDefSafeCust, PrihodRVenderPin  
  from dbo.PrihodReq 
  where PrihodRID=@PrihodRID
      
  select @NewPrihodRID=@@IDENTITY
  if @only_header=0
  begin
  insert into dbo.PrihodReqDet (PrihodRID, PrihodRDetHitag, PrihodRDetPrice, PrihodRDetCost, PrihodRDetTaraDSK, PrihodRDetLocked,
  															PrihodRDetStorage, PrihodRDetLevel, PrihodRDetIndex, PrihodRDetNLine, PrihodRDetDepth, PrihodRDetVolum, 
  														  PrihodRDetGtd, PrihodRDetAddrID, PrihodRDetClone, PrihodRDetCloneMain, PrihodRDetSummaPrice, PrihodRDetKolStr,
  															PrihodRDetSummaCost, PrihodRDetOperatorID, PrihodRDetDate, PrihodRDetSrokh, PrihodRDetSkladID, PrihodRDetIsSave,
  															PrihodRDetTara, PrihodRDetCheck, PrihodRDetNCom, 
                                QTY,  
                                --PrihodRDetKol, PrihodRDetWeigth, 
                                PrihodRDetTaraVendID,	PrihodRDetShelfLife, PrihodRDetShelfLifeAdd, PrihodRDetLockID, PrihodRDetAfterParty, 
                                PrihodRDetMainCloneKolStr, PrihodRDetMainCloneKol, PrihodRDetflg1kg)
	select 
  	@NewPrihodRID, PrihodRDetHitag, PrihodRDetPrice, PrihodRDetCost, PrihodRDetTaraDSK, PrihodRDetLocked, PrihodRDetStorage,
  	PrihodRDetLevel, PrihodRDetIndex, PrihodRDetNLine, PrihodRDetDepth, PrihodRDetVolum, PrihodRDetGtd, PrihodRDetAddrID, 
  	PrihodRDetClone, PrihodRDetCloneMain, PrihodRDetSummaPrice, PrihodRDetKolStr, PrihodRDetSummaCost, @op, getdate(), 
 	  PrihodRDetSrokh, PrihodRDetSkladID, 0, PrihodRDetTara, PrihodRDetCheck, 0, 
    QTY,  
    --PrihodRDetKol, PrihodRDetWeigth, 
    PrihodRDetTaraVendID, PrihodRDetShelfLife, PrihodRDetShelfLifeAdd, PrihodRDetLockID, PrihodRDetAfterParty,
  	PrihodRDetMainCloneKolStr, PrihodRDetMainCloneKol, PrihodRDetflg1kg
	from dbo.PrihodReqDet where prihodrid=@PrihodRID
  end
if @@error=0
	begin
  	commit tran @tranname
  	select cast(@NewPrihodRID as int) n, cast('' as varchar(100)) as Res
  end
else
	begin
		rollback tran @tranname
  	select cast(-1 as int) n, cast('При копировании возникла ошибка' as varchar(100)) as Res
  end