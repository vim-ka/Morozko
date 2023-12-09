CREATE PROCEDURE [LoadData].ITRPNomenGroups
AS
BEGIN
  select 0 as VID,
         ngrp, 
         0 as pin,
         grpname
         
  from gr 
  where Parent=0
  
  union 
  
  select distinct 1 as VID,
         iif(g.parent=0, g.ngrp,[dbo].[GetGrOnlyParent](e.ngrp)) as ngrp,
         f.pin, 
         f.brName
  from nomenvend n join nomen e on n.hitag=e.hitag 
                   join defcontract d on n.dck=d.dck
                   join def f on f.ncod=d.pin -- поменять на ncod  
                   join gr g on e.ngrp=g.ngrp
  where g.aginvis=0                 
  
END