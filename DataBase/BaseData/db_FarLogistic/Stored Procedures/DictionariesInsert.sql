CREATE PROCEDURE db_FarLogistic.DictionariesInsert
@ind int 
AS
declare @sql varchar(500)
set @sql= case 	when @ind=1 then ''
								when @ind=2 then 'insert into db_FarLogistic.dlDef(isvendor,MorozDefPin) values(1,-1)'
								when @ind=3 then 'insert into db_FarLogistic.dlDelivPoint(isdel) values(0)'
								when @ind=4 then 'insert into db_FarLogistic.dlVehicles(isdel) values(0)'
								else ''
					end
set @sql=@sql+' select isnull(@@identity,-1) [ID]'
exec(@sql)