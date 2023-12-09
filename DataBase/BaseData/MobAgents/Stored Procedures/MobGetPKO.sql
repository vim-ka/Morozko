CREATE PROCEDURE MobAgents.MobGetPKO @ag_id int
AS
BEGIN
   
  create table #NeedAg_ID (ag_id int)
  
/*  insert into #NeedAg_ID (ag_id)
  select a.ag_id from agentlist a where a.sv_ag_id=@ag_id or a.ag_id in (select b.add_ag_id from agaddbases b where b.ag_id=@ag_id and b.add_ag_id<>0)
 */ 
 declare @ND datetime
 set @ND = dbo.today()
 
 declare @SkipDover bit
 set @SkipDover=(select SkipDover from agentlist a where a.ag_id=@ag_id)
 
  
 select Our_id, DovNom as NomPKO
 from Dover 
 where DovStat=1 and @ND>=NDBeg and @ND<=NDEnd and 
       (ag_id=@ag_id or ag_id in (select ag_id from #NeedAg_ID))
  
 union 
  
 select c.our_id, 'пусто,опл не пройдет'
 from FirmsConfig c where c.Actual=1 and @SkipDover<>1
 order by Our_id, DovNom

END