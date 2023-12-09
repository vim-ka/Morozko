CREATE FUNCTION dbo.GetTime () RETURNS CHAR(8)
AS
BEGIN
  Return cast(Convert(varchar,getdate(),8) as CHAR(8))
END