CREATE PROCEDURE dbo.ClonePrihodRDet
@PrihodRDetID int,
@OP int
AS
declare @tranname varchar(15)
set @tranname='ClonePrihodRDet'
begin tran @tranname
	declare @NClone int
  declare @Kol varchar(10)
  declare @kol_int int
  declare @minp int
  
  if exists(select * from nomen n where n.flgWeight=1 and n.hitag=(select PrihodRDethitag from PrihodReqDet where PrihodRDetID=@PrihodRDetID))
  begin
  	select @kol_int=(select PrihodRDetKol from PrihodReqDet where PrihodRDetID=@PrihodRDetID)
  end
  else
  begin
  	select @minp=minp from nomen n where n.hitag=(select PrihodRDethitag from PrihodReqDet where PrihodRDetID=@PrihodRDetID)
  	exec dbo.TransInUnit @kol, @minp, @kol_int out
  end
  
	select 	@NClone=p.PrihodRDetClone, 
  				@Kol=p.PrihodRDetKolStr 
  from PrihodReqDet p 
  where p.PrihodRDetID=@PrihodRDetID
  
  if @NClone=0
  begin
  	select @NClone=max(p.PrihodRDetClone)+1 
    from PrihodReqDet p 
    where p.PrihodRID=(select PrihodRID from PrihodReqDet where PrihodRDetID=@PrihodRDetID)
    
  	update PrihodReqDet set PrihodRDetCloneMain=1,
    												PrihodRDetClone=@NClone,
    												PrihodRDetMainCloneKolStr=@Kol,
                            PrihodRDetMainCloneKol=@kol_int
    where PrihodRDetID=@PrihodRDetID     
  end
	
  insert into PrihodReqDet(
                PrihodRID,
                PrihodRDetHitag,
                PrihodRDetPrice,
                PrihodRDetCost,
                PrihodRDetTaraDSK,
                PrihodRDetLocked,
                PrihodRDetStorage,
                PrihodRDetLevel,
                PrihodRDetIndex,
                PrihodRDetNLine,
                PrihodRDetDepth,
                PrihodRDetVolum,
                PrihodRDetGtd,
                PrihodRDetAddrID,
                PrihodRDetClone,
                PrihodRDetCloneMain,
                PrihodRDetSummaPrice,
                PrihodRDetKolStr,
                PrihodRDetSummaCost,
                PrihodRDetOperatorID,
                PrihodRDetDate,
                PrihodRDetSrokh,
                PrihodRDetSkladID,
                PrihodRDetIsSave,
                PrihodRDetTara,
                PrihodRDetCheck,
                PrihodRDetNCom,
                PrihodRDetKol,
                PrihodRDetWeigth,
                PrihodRDetTaraVendID,
                PrihodRDetShelfLife,
                PrihodRDetShelfLifeAdd,
                PrihodRDetLockID,
                PrihodRDetAfterParty,
                PrihodRDetMainCloneKolStr,
                QTY,
                unid) 
select  
                PrihodRID,
                PrihodRDetHitag,
                PrihodRDetPrice,
                PrihodRDetCost,
                PrihodRDetTaraDSK,
                PrihodRDetLocked,
                PrihodRDetStorage,
                PrihodRDetLevel,
                PrihodRDetIndex,
                PrihodRDetNLine,
                PrihodRDetDepth,
                PrihodRDetVolum,
                PrihodRDetGtd,
                PrihodRDetAddrID,
                @NClone,
                0,
                0,
                '0',
                0,
                PrihodRDetOperatorID,
                PrihodRDetDate,
                PrihodRDetSrokh,
                PrihodRDetSkladID,
                PrihodRDetIsSave,
                PrihodRDetTara,
                PrihodRDetCheck,
                PrihodRDetNCom,
                0,
                PrihodRDetWeigth,
                PrihodRDetTaraVendID,
                PrihodRDetShelfLife,
                PrihodRDetShelfLifeAdd,
                PrihodRDetLockID,
                PrihodRDetAfterParty,
                0,
                QTY,
                unid
from PrihodReqDet
where PrihodRDetID=@PrihodRDetID

if @@error=0 
	begin
  commit tran @tranname
  select cast(0 as bit) n, cast('' as varchar(100)) as Res
  end
else
	begin
	rollback tran @tranname
  select cast(1 as bit) n, cast('Во время выполнения произошла ошибка' as varchar(100)) as Res
  end