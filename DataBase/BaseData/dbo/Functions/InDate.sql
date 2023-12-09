CREATE FUNCTION dbo.InDate (@ND datetime)
RETURNS datetime
AS
BEGIN
  return cast(floor(cast(@ND as decimal(38,19))) as datetime)
END