CREATE FUNCTION dbo.StartOfTheYear(@ND datetime) RETURNS datetime
AS
BEGIN
  declare @intDay datetime
  set @intDay=DATEADD(day, DATEDIFF(day, 0, @nd), 0);
  return dateadd(day,1-datepart(dayofyear,@intDay),@intDay)
end;