CREATE FUNCTION NearLogistic.GetRecCount(@mhid INT, @casher_id INT, @nal bit)
RETURNS INT
AS
BEGIN
  DECLARE @res INT
  SET @res = ISNULL(
  (SELECT count(b.reqid) 
    FROM NearLogistic.bills b 
   WHERE b.mhid = @mhid
     AND b.casher_id = @casher_id 
     AND b.nal = @nal 
     AND b.reqID <> -1
  ), -1)

RETURN @res
END