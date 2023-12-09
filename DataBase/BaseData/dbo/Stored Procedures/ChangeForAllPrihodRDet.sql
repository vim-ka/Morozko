CREATE PROCEDURE dbo.ChangeForAllPrihodRDet
@PrihodRDetID int
AS
declare @tranname varchar(22)
set @tranname='ClonePrihodRDet'
begin tran @tranname

	update nomen set LastCountryID=(select LastCountryID from nomen where hitag=(select PrihodRDetHitag from PrihodReqDet where PrihodRDetID=@PrihodRDetID)),
  								 LastProducerID=(select LastProducerID from nomen where hitag=(select PrihodRDetHitag from PrihodReqDet where PrihodRDetID=@PrihodRDetID))
  where hitag in (select PrihodRDetHitag from PrihodReqDet where PrihodRID=(select PrihodRID from PrihodReqDet where PrihodRDetID=@PrihodRDetID) and PrihodRDetID<>@PrihodRDetID)


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