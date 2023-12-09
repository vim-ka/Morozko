CREATE PROCEDURE dbo.CancelVetMarsh
@mhID int
AS
BEGIN
  delete from NearLogistic.MarshRequests where mhid=@mhID and ReqType=4 
  delete from MarshSertif where mhid=@mhID
END