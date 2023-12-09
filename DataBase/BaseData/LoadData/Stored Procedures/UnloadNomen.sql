CREATE PROCEDURE LoadData.UnloadNomen @hitag int
AS
BEGIN
  select n.hitag,
         n.name,
         n.fname,
         case when n.flgWeight=1 then 'кг' else 'шт' end as EdIzm,
         n.nds,
         n.Ngrp as Grp,
         case when n.flgWeight=1 then 0 else 1 end as SKUType,
         n.VolMinp as Volume,
         n.netto as Weigth,
         n.minp as minp
  from nomen n 
  where (n.hitag=@hitag) or (@hitag=0)
END