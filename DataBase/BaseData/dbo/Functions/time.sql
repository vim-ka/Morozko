CREATE FUNCTION dbo.time ()
RETURNS char(8)
AS
BEGIN
  return Left(Convert(varchar,getdate(),8),8)
END