CREATE view ActualSales
as select nc.*,nv.nvid, nv.tekid, nv.hitag, nv.price, nv.cost,
nv.kol, nv.kol_b, nv.sklad, nv.baseprice
from nc,nv
where nc.datnom = nv.DatNom
and nc.nd >= cast((year(CURRENT_TIMESTAMP)*10000+month(CURRENT_TIMESTAMP)*100+1) as varchar)