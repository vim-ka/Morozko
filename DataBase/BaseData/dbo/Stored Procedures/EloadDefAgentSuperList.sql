CREATE PROCEDURE dbo.EloadDefAgentSuperList
@wostamp int
AS
BEGIN
  select distinct
         de.depid [КодОтдела],
         de.DName [НаименованиеОтдела],
         s.AG_ID [КодСуперВизора],
         sp.fio [ФИОСуперВизора],
         a.AG_ID [КодАгента],
         ap.fio [ФИОАгента],
         d.pin [КодТочки],
         d.brName [НаименованиеТочки],
         d.gpAddr [АдресДоставки] 
  from defcontract dc
  inner join def d on d.pin=dc.pin
  inner join agentlist a on a.ag_id=dc.ag_id
  inner join agentlist s on a.sv_ag_id=s.ag_id
  inner join deps de on de.DepID=a.depid
  inner join person ap on ap.p_id=a.p_id
  inner join person sp on sp.p_id=s.p_id
  where dc.ContrTip=2
        and dc.actual=1
        and d.actual=1
        and d.Master=0
        and de.Sale=1
        and d.Worker=0
        and d.wostamp=iif(@wostamp=-1,d.wostamp,cast(@wostamp as bit))
        and dc.Degust=0
  order by de.DName,sp.fio,ap.fio,d.brname
END