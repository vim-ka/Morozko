CREATE FUNCTION dbo.period_to_table (@nd1 datetime, @nd2 datetime, @step float = 1.0, @step_type varchar(3) ='day')
RETURNS @res table(AField datetime)
as begin
	declare @nd datetime
  set @nd=@nd1
  while @nd<=@nd2 
  begin
  	insert into @res values(@nd)  	
    set @nd= case when @step_type='day' then dateadd(day,1,@nd)
    							else dateadd(day,1,@nd) end
  end
  return
end