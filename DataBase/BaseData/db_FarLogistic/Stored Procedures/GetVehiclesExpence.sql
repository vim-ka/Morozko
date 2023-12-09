CREATE PROCEDURE db_FarLogistic.GetVehiclesExpence
@isDel bit =0,
@n int =1
AS
BEGIN
	declare @c int 
	select @c=month(a.ExpenceDate)
	from db_FarLogistic.dlVehicleExpence a
	where a.ExpenceID=(select max(ExpenceID) from db_FarLogistic.dlVehicleExpence where isdel=0)
	
	if month(getdate())-@c>@n
	set @n=month(getdate())-@c
	
  select 	e.ExpenceID [id],
					e.ExpenceDate,
					e.dlVehicleID,
					(select v.Model+' {'+v.RegNom+'}' from db_FarLogistic.dlVehicles v where v.dlVehiclesID=e.dlVehicleID) [veh],
					e.ExpenceListID,
					(select l.ExpenceName from db_FarLogistic.dlExpenceList l where l.ExpenceListID=e.ExpenceListID ) [list],
					e.ExpenceCom,
					e.ExpenceSum,
					e.GroupsID,
					e.IsDel 
		from db_FarLogistic.dlVehicleExpence e
		where e.IsDel in (0, @isDel)
					and e.ExpenceDate >= dateadd(month, @n*(-1), getdate())
		order by e.ExpenceDate desc, 
						 e.GroupsID
END