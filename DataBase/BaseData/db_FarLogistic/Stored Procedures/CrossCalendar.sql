CREATE PROCEDURE [db_FarLogistic].CrossCalendar
@m varchar(3),
@y varchar(5) 
AS
BEGIN	
  declare @sql varchar(max)
  declare @daycount int 
  declare @i int
  set @i=1 
  select @daycount=cast((DATEADD(m,1,cast('01/'+@m+'/'+@y as datetime))-cast('01/'+@m+'/'+@y as datetime)) as int)
  set @sql='select * from db_FarLogistic.dlDrivers d'  
  while @i<=@daycount
  begin
  	set @sql=@sql+' left join db_FarLogistic.dlCalendar c'+cast(@i as varchar(2))+'  on c'+cast(@i as varchar(2))+'.IDDrv=d.ID and  day(c'+cast(@i as varchar(2))+'.CalDate)='+cast(@i as varchar(2))+' and month(c'+cast(@i as varchar(2))+'.CalDate)='+@m+' and year(c'+cast(@i as varchar(2))+'.CalDate)='+@y
    set @i=@i+1
  end
  exec(@sql)
END