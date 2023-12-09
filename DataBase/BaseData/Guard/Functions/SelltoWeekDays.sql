CREATE FUNCTION [Guard].SelltoWeekDays (@pin int, @NeedDay date
)
RETURNS char(20)
AS
BEGIN
  declare @sunday date, @dn tinyint
  
  set @dn = datepart(weekday, @NeedDay)
  if @dn = 7 set @dn = 0
  set @sunday = dateadd(day, -@dn, @NeedDay)
  
  
  /*insert into #Temp
  select distinct t.WeekDays from
  (select case when datepart(weekday, c.nd) = 1 then 'пн,'
              when datepart(weekday, c.nd) = 2 then 'вт,'
              when datepart(weekday, c.nd) = 3 then 'ср,'
              when datepart(weekday, c.nd) = 4 then 'чт,'
              when datepart(weekday, c.nd) = 5 then 'пт,'
              when datepart(weekday, c.nd) = 6 then 'сб,'
              when datepart(weekday, c.nd) = 7 then 'вс,' end as WeekDays
  from nc c
  where c.b_id = @pin and c.nd between @sunday and @NeedDay
  ) t*/
  
  
  
  
   
  return @sunday
END