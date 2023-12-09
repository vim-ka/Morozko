CREATE procedure Guard.UpdControlVisit @ag_id int=0
as
begin
  create table #t(ag_id int, pin int);
  
  insert into #t
  select distinct ag_id, b_id as pin from nc where nd=dbo.today()
  UNION
  select distinct f.ag_id, dc.pin
  from guard.FMonitor f
    inner join Defcontract dc on dc.dck=f.DCK
  where f.ND=dbo.today()
  UNION
  select distinct nc.ag_id, k.B_ID as pin
  from Kassa1 k
    inner join nc on nc.datnom=k.sourdatnom
  where k.oper=-2 and k.nd=dbo.today();

  update guard.ControlVisit
  set done=1 
  from guard.ControlVisit v inner join #t on #t.ag_id=v.ag_id and #t.pin=v.pin;

  select v.ag_id, v.pin, p.fio, p.phone, def.gpname, dbo.fnMinutes2str(v.tm)  as PlanT, v.tm
  from 
    guard.ControlVisit v 
    inner join def on def.pin=v.pin
    inner join Agentlist A on a.ag_id=v.ag_id
    inner join Person P on P.P_ID=a.p_id
  where 
    v.done=0
    and v.tm<=datepart(HOUR, getdate())*60+datepart(MINUTE, getdate())-30
    and (@ag_id=0 or v.ag_id=@ag_id)
  order by v.ag_id, v.tm;
end;