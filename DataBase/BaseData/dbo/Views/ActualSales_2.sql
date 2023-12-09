CREATE view ActualSales_2
as select nv.nvid, nv.tekid, nv.hitag, nv.price, nv.cost, nv.kol, nv.kol_b, nv.sklad, nv.baseprice, nc.*
from nc,nv
where nc.datnom = nv.DatNom
and nc.nd between cast((year(CURRENT_TIMESTAMP -60)*10000+month(CURRENT_TIMESTAMP -60)*100+1) as varchar)
and cast((year(CURRENT_TIMESTAMP-30)*10000+month(CURRENT_TIMESTAMP-30)*100+1) as varchar)