CREATE FUNCTION CalcVolumeNakl (@DatNom int) RETURNS numeric(10,3)
AS
BEGIN
 declare @Volume numeric(10,3)

 select @Volume=sum(v.kol*isnull(n.volminp,0))
 from nv v left join nomen n on v.hitag=n.hitag
 where v.datnom=@DatNom   
   
 return @Volume
END