CREATE PROCEDURE db_FarLogistic.GetDistances
@MarshID int,
@WorkID int,
@All bit=0
AS
BEGIN
	declare @sql varchar(500)
  set @sql='
	select * 
	from db_FarLogistic.GetDistanceTable('+cast(@MarshID as varchar)+','+cast(@WorkID as varchar)+')'
	if @All=0 
		set @sql=@sql+' where Distance<0'
		
	exec(@sql)
END