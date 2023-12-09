
CREATE PROCEDURE NearLogistic.GetDriverVehicleInDate
@nd datetime
AS
BEGIN
  select v_id, 
      drid 
  from dbo.VehRasp 
  where PlanDay=@nd 
  and (not RaspType in (4,5,6,7) 
     or TRY_PARSE(tmWork as time) is not null)
END