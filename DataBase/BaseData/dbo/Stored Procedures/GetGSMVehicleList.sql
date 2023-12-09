CREATE PROCEDURE dbo.GetGSMVehicleList
@our_id int
AS
BEGIN
	if @our_id=14
  select  v.dlVehiclesID [id],
          v.Model+' '+v.RegNom [list]
  from db_FarLogistic.dlVehicles v
  where v.dlMainVehID=-1
else
	if @our_id=7
    select v.v_id [id],
           v.Model+' '+v.RegNom [list]
    from dbo.Vehicle v
    where v.Trailer=0
          and v.CrId=7
          and v.v_id<>0
    union 
    select -1, 'нет'
   else
   	select -1 [id], 'нет' [list]
END