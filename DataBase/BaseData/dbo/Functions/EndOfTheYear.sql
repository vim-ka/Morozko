CREATE FUNCTION dbo.EndOfTheYear(@ND datetime) RETURNS datetime
AS
BEGIN
  declare @intDay datetime
  set @intDay=DATEADD(day, DATEDIFF(day, 0, @nd), 0);
  return convert(datetime,'12/31/'+convert(char(4),year(@IntDay)),101)
end;