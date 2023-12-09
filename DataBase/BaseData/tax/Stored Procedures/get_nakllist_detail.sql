CREATE procedure tax.get_nakllist_detail
@datnom int
as
begin
set nocount on
select v.hitag,v.kol,v.price,n.name,iif(n.flgWeight=0, n.Netto, isnull(t.weight,s.weight)) [netto],
       c.extra,v.cost,v.price*v.kol [sumprice],v.cost*v.kol [sumcost],round((v.price*((1+c.extra/100))),2)*v.kol [sumprextra],
       round((v.price*((1+c.extra/100))),2) [priceextra],v.kol_b,
       iif(n.flgWeight=0, round((v.price*(1+c.extra/100)/iif(n.netto=0,1,n.netto)),2),round((v.price*(1+c.extra/100)/iif(isnull(t.weight,s.weight)=0,1,isnull(t.weight,s.weight))),2)) [prweight],
       iif(n.cost<>0,round(((v.price*(1+c.extra/100)-v.cost)/v.cost)*100,1), null) [resextra]
from dbo.nc c 
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.nomen n on n.hitag=v.Hitag
left join dbo.tdvi t on v.tekid=t.id
left join dbo.visual s on v.tekid=s.id
where v.datnom=@datnom
order by v.hitag
set nocount off
end