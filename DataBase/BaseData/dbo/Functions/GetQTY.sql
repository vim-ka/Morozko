CREATE FUNCTION dbo.GetQTY (@hitag INT, @unid INT, @QTY DECIMAL(18,4), @needUnid INT=-1)  
RETURNS DECIMAL(18,4)
AS 
BEGIN 
  DECLARE @needQTY DECIMAL(18,4)
  IF @needUnid = -1 
  SET @needUnid = (SELECT nomen.unid FROM nomen WHERE hitag = @hitag)
  IF @unid = @needUnid
  SET @needQTY = @QTY
  ELSE 
  IF NOT EXISTS(SELECT uc.Unid2 FROM unitconv uc WHERE uc.Hitag = @hitag AND uc.Unid2 = @needUnid AND uc.isdel = 0)
  SET @needQTY = NULL
  
  ELSE 
  BEGIN 
    SET @needQTY = 
    (SELECT @QTY*uc.K
       FROM unitconv uc 
      WHERE uc.Hitag = @hitag
        AND uc.Unid = @unid
        AND uc.Unid2 = @needUnid
        AND uc.isdel = 0
    )
  END 
  RETURN @needQTY
END