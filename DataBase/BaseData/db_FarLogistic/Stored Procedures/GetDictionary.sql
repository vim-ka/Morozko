CREATE PROCEDURE db_FarLogistic.GetDictionary
@ind int,
@ShowAll bit
AS
declare @sql varchar(500)
declare @IsDel int 
set @IsDel=case when @ShowAll=1 then 1 else 0 end
set @sql=
case 	when @ind=1 then 
				'select * from db_FarLogistic.dlDrivers where IsDel in (0,'+cast(@IsDel as varchar)+')'
			when @ind=2 then 
				'select * from db_FarLogistic.dlDef where IsDel in (0,'+cast(@IsDel as varchar)+')'
			when @ind=3 then 
				'select * from db_FarLogistic.dlDelivPoint where IsDel in (0,'+cast(@IsDel as varchar)+')'
			when @ind=4 then 
				'select * from db_FarLogistic.dlVehicles where IsDel in (0,'+cast(@IsDel as varchar)+')'
			else
				'select -1 [id],''Спрвочник не назначен'' [name], cast(0 as bit) [isdel]'
end

exec(@sql)