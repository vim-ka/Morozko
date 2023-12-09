CREATE FUNCTION Round5kop (@nn decimal(14,4)) RETURNS decimal(12,2)
AS
BEGIN
 declare @r decimal(12,2);
 
 if @nn<0 set @r=-0.5*round(-@nn*2+0.04999, 1)
 else set @r=0.5*round(@nn*2+0.04999, 1); 
 
 return @r;
END