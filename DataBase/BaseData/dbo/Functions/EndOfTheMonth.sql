CREATE FUNCTION dbo.EndOfTheMonth(@ND datetime) RETURNS datetime
AS
BEGIN
  declare @intDay datetime
  set @intDay=DATEADD(day, DATEDIFF(day, 0, @nd), 0);
  return dateadd(month,1,dateadd(day,1-day(@intDay),@intDay))-1
END