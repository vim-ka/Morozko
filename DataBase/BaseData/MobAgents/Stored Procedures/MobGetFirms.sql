CREATE PROCEDURE [MobAgents].MobGetFirms @ag_id int
AS
BEGIN
  select c.Our_ID, f.OurName, c.DCK as pin,c.ag_id as brAg_id
  from defcontract c join FirmsConfig f on c.our_id=f.our_id
  where c.ContrTip=2 and 
  (c.ag_id=@ag_id or c.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
                  or c.dck in (select b.add_dck from agaddbases b where b.ag_id=@ag_id and b.add_dck<>0))

  order by c.Our_ID, c.DCK 
END