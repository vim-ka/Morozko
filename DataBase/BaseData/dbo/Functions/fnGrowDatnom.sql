CREATE FUNCTION dbo.fnGrowDatnom (@datnom int) RETURNS bigint
AS
BEGIN
  DECLARE @REZ bigint
  SET @REZ = @datnom / 10000 
  SET @REZ = @REZ * 100000
  SET @REZ = @REZ + @datnom % 10000
  return @REZ
END