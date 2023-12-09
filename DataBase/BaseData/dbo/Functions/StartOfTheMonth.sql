CREATE FUNCTION dbo.StartOfTheMonth(@ND datetime) RETURNS datetime
AS
BEGIN
  declare @intDay datetime
  set @intDay=DATEADD(day, DATEDIFF(day, 0, @nd), 0);
  return dateadd(day,1-day(@intDay),@intDay)
END