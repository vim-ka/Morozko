CREATE FUNCTION NearLogistic.GetRealDistance (@mhid INT, @dist INT)
RETURNS FLOAT
AS
BEGIN
DECLARE @dist1 FLOAT, @sumdist FLOAT, 
        @marshdist float, @realdist FLOAT

  SET @marshdist = 
    (SELECT IIF(ISNULL(m.Dist,0) = 0, ISNULL(m.CalcDist,0), ISNULL(m.Dist,0))
       FROM marsh m 
      WHERE m.mhid = @mhid
    )

  SET @dist1 = CAST(@dist AS FLOAT)/1000.0
  
  SET @sumdist = 
  (SELECT SUM(CAST(b.distance AS float)) 
     FROM NearLogistic.bills b
    WHERE b.mhid = @mhid
  )
 
  SET @sumdist = @sumdist/1000.0
   
  SET @realdist = IIF(@sumdist*@marshdist = 0, 0,
                      ROUND(@dist1/@sumdist*@marshdist*1000, 3))

  RETURN @realdist
END