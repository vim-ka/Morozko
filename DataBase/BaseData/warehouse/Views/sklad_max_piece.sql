CREATE VIEW warehouse.sklad_max_piece
AS
  select v.sklad,v.hitag,max(cast(iif(n.flgweight=1,v.weight,n.netto*(v.morn-v.sell+v.isprav-v.remov)) as money)) [weight]
  from dbo.tdvi v
  join dbo.nomen n on n.hitag=v.hitag
  where v.sklad>0
  			and v.morn-v.sell+v.isprav-v.bad-v.remov>0
  group by v.sklad,v.hitag