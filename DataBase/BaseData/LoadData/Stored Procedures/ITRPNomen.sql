CREATE PROCEDURE [LoadData].ITRPNomen
AS
BEGIN
  select 1 as VID,
         grpname as name,
         '' as ed_izm,
         0 as nds,
         parent as code_ng,
         ngrp as vk  
  from GR
  
  union
  
  select 0 as VID,
         name as name,
         case when flgWeight = 1 then 'кг' else 'шт' end  as ed_izm,
         nds as nds,
         ngrp as code_ng,
         hitag as vk  
  from nomen

END