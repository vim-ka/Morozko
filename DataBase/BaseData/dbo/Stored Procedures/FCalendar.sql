CREATE PROCEDURE dbo.FCalendar @day0 datetime, @day1 datetime
AS
BEGIN
  --заготовка для ГСМ
  declare @daycnt datetime
  set @daycnt = @day0
  if object_id('tempdb..#fc') is not null drop table #fc
  create table #fc(dt datetime, vol numeric(10, 2), dist numeric(10, 2), p_id int)
--  insert into #fc(dt) values(@daycnt)
  while @daycnt < @day1 
  begin
    insert into #fc(dt) values(@daycnt)
    print @daycnt
    set @daycnt = @daycnt + 1    
  end
  select * from #fc
END