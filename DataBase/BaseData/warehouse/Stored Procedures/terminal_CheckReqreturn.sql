CREATE PROCEDURE warehouse.terminal_CheckReqreturn
@retid int
AS
BEGIN
	select cast(iif(exists(select 1 from dbo.requests r join dbo.reqreturndet d on d.reqretid=r.rk where r.tip2=197 and done=0 and r.rk= @retid ),1,0) as bit) [res]
END