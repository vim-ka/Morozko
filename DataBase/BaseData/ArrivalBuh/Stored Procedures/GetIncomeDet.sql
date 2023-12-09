CREATE PROCEDURE ArrivalBuh.GetIncomeDet
@ncom int
AS
BEGIN
  select i.sklad,
		 i.hitag, 
		 n.name as [lookname],
         i.[weight],
         i.kol,
         i.cost,
         i.price,
         i.summacost,
         i.price*i.kol [summaprice],
         isnull(t.MORN-t.SELL+t.isprav-t.REMOV,0) [ost],
         isnull(t.COST,0) [tdvicost],
         isnull(t.PRICE,0) [tdviprice]
  from inpdet i
  left join nomen n on n.hitag=i.hitag
  left join tdvi t on i.id=t.id
  where i.ncom=@ncom
END