CREATE PROCEDURE NearLogistic.PrintApplicationForLogicalOrders
@mhID int
AS
BEGIN
select m.nd, m.marsh, c.fam, s.Fio as Driver,dbo.InNnak(c.datnom) as NNak, c.stfnom, d.gpAddr
from Marsh m 
left join  nc c on  c.nd=m.nd and c.mhid=m.mhid and c.stip=4
left join Def d on c.b_id=d.pin
left join Drivers s on m.drID=s.drID
where m.mhid=@mhid 
END