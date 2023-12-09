CREATE FUNCTION CalcWeightNakl (@DatNom int) RETURNS numeric(10,3)
AS
BEGIN
 declare @Massa numeric(10,3)

if dbo.DatNomInDate(@DatNom) = dateadd(Day,datediff(Day,0,getdate()),0)

 select @Massa=isnull(sum(v.kol*(iif(vi.weight>0,vi.weight, isnull(n.netto,0)))),0) 
 from nv v left join nomen n on v.hitag=n.hitag
           left join tdvi vi on v.tekid=vi.id 
 where v.datnom=@DatNom   
 
 else
 
 select @Massa=isnull(sum(v.kol*(iif(vi.weight>0,vi.weight, isnull(n.netto,0)))),0) 
 from nv v left join nomen n on v.hitag=n.hitag
           left join visual vi on v.tekid=vi.id 
 where v.datnom=@DatNom   

   
 return @Massa 
END