CREATE PROCEDURE db_FarLogistic.GetDictionaryCard
@ind int,
@ID int
AS
declare @sql varchar(500)
set @sql=
case 	when @ind=1 then 
				'select * from db_FarLogistic.dlDrivers where ID='+cast(@ID as varchar)
			when @ind=2 then 
				'select * from db_FarLogistic.dlDef where ID='+cast(@ID as varchar)
			when @ind=3 then 
				'select * from db_FarLogistic.dlDelivPoint where dlDelivPointID='+cast(@ID as varchar)
			when @ind=4 then 
				'select * from db_FarLogistic.dlVehicles where dlVehiclesID='+cast(@ID as varchar)
			else
				'select -1 [id],''Спрвочник не назначен'' [name], cast(0 as bit) [isdel]'
end

exec(@sql)