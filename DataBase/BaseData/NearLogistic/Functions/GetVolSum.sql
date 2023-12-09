CREATE FUNCTION NearLogistic.GetVolSum(@mhid INT, @casher_id INT, @nal bit)
RETURNS decimal(15, 4)
AS
BEGIN
  DECLARE @res decimal(15, 4)
  SET @res = ISNULL(
  (SELECT SUM(ISNULL(bills.Vol,0)) 
    FROM bills 
   WHERE bills.mhid = @mhid
     AND bills.casher_id = @casher_id 
     AND bills.nal = @nal 
  ), 0)

RETURN @res
END