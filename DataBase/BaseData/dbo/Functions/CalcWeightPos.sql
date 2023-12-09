CREATE FUNCTION dbo.CalcWeightPos (@nvID int) RETURNS numeric(10,3)
AS
BEGIN
 declare @Massa numeric(10,3)
 declare @DatNom BIGint
 set @DatNom = (select datnom from nv where nvID=@nvID) 

if dbo.DatNomInDate(@DatNom) = dateadd(Day,datediff(Day,0,getdate()),0)

 select @Massa= isnull(sum(v.kol * IIF(v.unid=1, 1, isnull(UnitConv.k, n.netto))),0)
  --isnull(sum(v.kol*(case when vi.weight>0 then vi.weight else isnull(n.netto,0)  end)),0) 
 from nv v left join nomen n on v.hitag=n.hitag
           left join tdvi vi on v.tekid=vi.id 
 LEFT JOIN UnitConv ON v.hitag = UnitConv.Hitag 
                    AND UnitConv.unid = v.unid AND UnitConv.unid2 = 1   --для перевода в кг
 where v.nvID=@nvID
 
 else
 
 select @Massa= isnull(sum(v.kol * IIF(v.unid=1, 1, isnull(UnitConv.k, n.netto))),0)
  --isnull(sum(v.kol*(case when vi.weight>0 then vi.weight else isnull(n.netto,0)  end)),0) 
 from nv v left join nomen n on v.hitag=n.hitag
           left join visual vi on v.tekid=vi.id 
 LEFT JOIN UnitConv ON v.hitag = UnitConv.Hitag 
                    AND UnitConv.unid = v.unid AND UnitConv.unid2 = 1   --для перевода в кг
 where v.nvID=@nvID

   
 Return @Massa 
END