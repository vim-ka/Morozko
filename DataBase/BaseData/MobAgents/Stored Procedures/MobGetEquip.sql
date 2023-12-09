CREATE PROCEDURE MobAgents.MobGetEquip @ag_id int
AS
BEGIN

  create table #NeedDCK (dck int)
  
  insert into #NeedDCK (dck)
  select c.dck from defcontract c where c.ag_id=@ag_id or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
   union
  select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0


  select f.DCK as pin,
         0 as Kol,
         (f.NName+'#'+ (case when Len(f.FabNom)>0 then f.FabNom else '0' end)) as FabNom
  from frizer f join #NeedDCK nd on f.dck=nd.dck

  union        
  select 99999 as pin,
         0 as Kol,
         'TEST#5000000125494' as FabNom
   order by pin, FabNom

END