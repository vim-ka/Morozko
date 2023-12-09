CREATE PROCEDURE db_FarLogistic.DictionariesDelete
@ind int, 
@ID int
AS
declare @sql varchar(500)
set @sql= case 	when @ind=1 then 'delete from db_FarLogistic.dlDrivers where id='+cast(@ID as varchar)
								when @ind=2 then 'delete from db_FarLogistic.dlDef where ID='+cast(@ID as varchar)
								when @ind=3 then 'delete from db_FarLogistic.dlDelivPoint where dlDelivPointID='+cast(@ID as varchar)
								when @ind=4 then 'delete from db_FarLogistic.dlVehicles where dlVehiclesID='+cast(@ID as varchar)
								else ''
					end
exec(@sql)