
CREATE PROCEDURE NearLogistic.GetCargoConsist
@mhID int
AS
BEGIN
select c.DatNom % 10000 nNak,
    c.Fam,
    v.nvID,
    n.hitag,
       n.name,
       v.kol,
       iif(isnull(isnull(t.weight,s.weight),0)=0,v.kol*n.brutto,v.kol*isnull(isnull(t.weight,s.weight),0)) [weight]       
from NearLogistic.MarshRequests mr 
join dbo.nc c on mr.reqid=c.datnom
join dbo.nv v on c.DatNom=v.DatNom
join dbo.nomen n on n.hitag=v.hitag
left join dbo.tdvi t on t.id=v.tekid
left join dbo.Visual s on s.id=v.tekid
where mr.mhID=@mhID
   and mr.ReqType=0
order by c.datnom,n.name
END