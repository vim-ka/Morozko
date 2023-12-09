CREATE FUNCTION dbo.InNnak (@DatNom bigint) RETURNS int
AS
BEGIN
  return @datnom % 100000
END