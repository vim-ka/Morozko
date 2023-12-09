CREATE procedure FMonitorSkip @Day0 datetime, @Day1 datetime
as
begin
  select 
    a2.depId, Deps.DName,
    ag.sv_ag_id as SV_ID, P2.Fio as SuperFam,
    dc.ag_id, P.Fio as AgentFam, 
    A.Dck, def.pin, def.gpname  
  from (
    select 
      dc.dck
    from
      agentlist a
      inner join defcontract dc on dc.ag_id=a.ag_id
      inner join ( select distinct p.pin, p.ag_id
        from PlanVisit p 
        where p.dt1<>0 or p.dt2<>0 or p.dt3<>0 or p.dt4<>0 or p.dt5<>0 or p.dt6<>0 or p.dt7<>0
        )E on E.pin=dc.pin and e.ag_id=dc.ag_id
      inner join (select F.dck, count(f.dck) as FrizCnt from Frizer F  where F.Tip=0 and f.dck>0 group by F.DCK having count(f.dck)>0) FF on FF.dck=dc.dck
    EXCEPT
      select distinct dck from fmonitor where nd>=@Day0 and nd<=@Day1 )
    A
    inner join defcontract dc on dc.dck=a.dck
    inner join def on def.pin=dc.pin
    inner join Agentlist Ag on Ag.ag_id=dc.ag_id
    inner join Person P on P.p_id=ag.p_id
    inner join Agentlist A2 on A2.ag_id=ag.sv_ag_id
    inner join Person P2 on P2.p_id=a2.p_id
    inner join Deps on Deps.depid=a2.depid
  order by 
    a2.depId, 
    ag.sv_ag_id,
    dc.ag_id
end;