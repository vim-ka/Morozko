CREATE FUNCTION dbo.fnNDSDatnom (@DatNom int) RETURNS decimal(15,4)
AS
BEGIN
 declare @NDS decimal(15,4)

select @NDS=sum((1+c.extra/100)*100*v.price/(n.nds+100)*v.kol)  from nv v join nomen n ON v.hitag=n.hitag
                                                          join nc c on c.datnom=v.datnom
where v.datnom=@Datnom

   
 return @NDS 
END