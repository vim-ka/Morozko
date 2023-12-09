CREATE PROCEDURE dbo.CheckPrihodReqDet
@PrihodRID int,
@val bit
AS
declare @id int
declare cur cursor for
select p.PrihodRDetID
from PrihodReqDet p
where p.PrihodRID=@PrihodRID and p.PrihodRDetIsSave=0

open cur

fetch next from cur into @id 

while @@fetch_status=0 
begin
	update PrihodReqDet set PrihodRDetCheck=@val where PrihodRDetID=@id
  fetch next from cur into @id 
end

close cur
deallocate cur