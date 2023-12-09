

CREATE procedure dbo.PrepAgentsMsg_Del @Nd0 datetime 
as
begin
  create table #k(ag_id int, 
    SP decimal(12,2) default 0, 
    Plata decimal(12,2) default 0, 
    Overdue decimal(12,2) default 0);
  
  -- Продажи за период с начала месяца:
  insert into #k(ag_id, sp)  
  select dc.ag_id, sum(nc.sp) as SP
  from 
    nc
    inner join defcontract dc on dc.DCK=nc.DCK
  where 
    nc.srok>0 and nc.nd between '20130801' and '20130813'
  group by dc.ag_id
    
-- Выплаты за период:
  insert into #k(ag_id, Plata)  
  select dc.ag_id, sum(k.plata) as Plata
  from 
    kassa1 k
    inner join nc on nc.datnom=k.sourdatnom
    inner join defcontract dc on dc.DCK=nc.DCK
  where 
    k.oper=-2
    and k.nd between '20130801' and '20130813'
  group by dc.ag_id  


  -- Просроченная дебиторка:
  insert into #k(ag_id, Overdue)  
  SELECT
    dc.ag_id, sum(nc.sp-nc.fact+nc.Izmen) as Overdue
  from 
    nc inner join DefContract dc on dc.dck=nc.DCK
  where
    nc.srok>0 and nc.sp-nc.fact+nc.Izmen>0
    and nc.nd+nc.Srok<=GETDATE()
  group by dc.ag_id

  select #k.ag_id, L.Agent, sum(#k.SP) SP, sum(#k.Plata) Plata, sum(#k.Overdue) Overdue,
  L.ServerName, L.FolderName
  from #k inner join Agentlist L on L.AG_ID=#k.ag_id
  where #k.ag_id>0
  group by #k.ag_id, L.Agent, L.ServerName, L.FolderName
  order by #k.ag_id


end