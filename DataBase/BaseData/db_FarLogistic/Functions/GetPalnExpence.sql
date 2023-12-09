CREATE FUNCTION db_FarLogistic.GetPalnExpence (@id int, @VehID int, @dt datetime)
RETURNS money
AS
BEGIN
	declare @res money
  select 	@res=sum(case when @id=1 then isnull(z.Amort,0)
            						when @id=2 then isnull(z.Strah,0)
            						when @id=3 then isnull(z.Serv,0)
            						when @id=4 then isnull(z.Fuel,0)
												when @id=5 then isnull(z.DriverZar,0)
												when @id=6 then isnull(z.LogicZar,0)
												when @id=7 then isnull(z.Other,0)
            						when @id=8 then isnull(z.PriceKM,0) 
												when @id=9 then isnull(z.Amort+z.Strah+z.Serv+z.Fuel+z.DriverZar+z.LogicZar+z.Other,0) end) 
    from (
					select top 2 	e.Amort, 
												e.Serv, 
												e.Strah, 
												e.Fuel, 
												e.DriverZar, 
												e.LogicZar, 
												e.Other, 
												e.PriceKM
					from db_FarLogistic.dlExpence e
    			where e.IDVehTYpe in (select v.dlVehTypeID 
																from db_FarLogistic.dlVehicles v 
																where v.dlVehiclesID=@VehID
    														union all
                          			select v.dlVehTypeID 
																from db_FarLogistic.dlVehicles v 
																where v.dlVehiclesID=(select v.dlVehiclesID 
																											from db_FarLogistic.dlVehicles v 
																											where v.dlMainVehID=@VehID)
																)
								and e.DateStart<='160430'--@dt
					order by e.DateStart desc) z
	return @res
END