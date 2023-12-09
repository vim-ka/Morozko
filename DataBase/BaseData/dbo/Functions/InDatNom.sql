CREATE FUNCTION dbo.InDatNom (@NNak int, @ND datetime) RETURNS bigint
AS
BEGIN
  return CAST(CONVERT(varchar,@ND,12)+substring(cast(@NNak+100000 as varchar),2,5) as bigint)
END