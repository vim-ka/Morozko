CREATE PROCEDURE db_FarLogistic.DelExpence
@ExpenceID int
AS
BEGIN
  declare @gr int
	select @gr=e.GroupsID
	from db_FarLogistic.dlVehicleExpence e
	where e.ExpenceID=@ExpenceID
	
	if @gr=-1
		update db_FarLogistic.dlVehicleExpence set IsDel=1 where ExpenceID=@ExpenceID
	else
		update db_FarLogistic.dlVehicleExpence set IsDel=1 where GroupsID=@gr
END