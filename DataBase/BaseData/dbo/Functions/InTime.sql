CREATE FUNCTION dbo.InTime (@ND datetime)
RETURNS varChar(5)
AS
BEGIN
  return Left(Convert(varchar,@ND,8),5)
END