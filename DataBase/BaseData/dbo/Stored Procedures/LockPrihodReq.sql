create procedure dbo.LockPrihodReq
@PrihodRID int,
@val bit
as
begin
	update d set d.PrihodRDetLocked=@val
  from dbo.prihodreqdet d
  where d.prihodrid=@PrihodRID  			
end