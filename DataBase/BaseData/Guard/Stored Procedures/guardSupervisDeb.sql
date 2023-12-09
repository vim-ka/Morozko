CREATE PROCEDURE Guard.guardSupervisDeb @NeedDay datetime
AS
BEGIN
  declare @OP int
  declare @dn int -- день недели
  set @OP = 1000
  set @dn = datepart(weekday, @NeedDay)
  print('@DN='+cast(@DN as varchar))

  select s.DepId, d.DName, s.ag_id as sv_id,r.fio as fam, SUM(NaklAG) as NaklAG,SUM(NaklOp) as NaklOP, sum(PlanV) as PlanV, 
         case when isnull(sum(PlanV),0) = 0 then 0
         else (100*(SUM(NaklAG) + SUM(NaklOp))/sum(PlanV)) end as PlanProc,
  	0.00 as Debt, 0.00 as Overdue,
    CAST(iif(d.dep_chief=r.P_ID,1,0) as BIT) AS flgCHIEF
from 
    AgentList s 
    left join Person r on s.p_id=r.p_id 
    left join
    (select a.ag_id,r.fio,a.sv_ag_id,
      (select COUNT(distinct t.dck) from NC t where t.ND=@NeedDay and t.ag_id=a.ag_id and t.op>=@OP and t.sp>0 and t.RemarkOp not like 'w.%') as NaklAg,
      (select COUNT(distinct t.dck) from NC t where t.ND=@NeedDay and t.ag_id=a.ag_id and t.op<@OP and t.sp>0 and t.RemarkOp not like 'w.%') as NaklOp,
      (select COUNT(p.pin) from PlanVisit2 p where p.dn=@dn and p.ag_id=a.ag_id) as PlanV,
      (select COUNT(distinct k.dck) from Kassa1 k, AgentList ag where k.nd=@NeedDay and k.oper=-2 and k.Op=ag.NomerOp and ag.ag_id=a.ag_id) as KolVyp,
      (select COUNT(distinct r.pin) from Rests r where r.nd>=@NeedDay and r.nd < dateadd(day,1,@NeedDay) and r.ag_id=a.ag_id) as kolAudit,
      (select COUNT(distinct ao.pin) from AdvOrder ao where ao.nd=@NeedDay and ao.ag_id=a.ag_id) as kolAdvOrd
      from AgentList a left join Person r on r.p_id=a.P_ID
    ) p on p.sv_ag_id=s.ag_id
    left join Deps d on s.DepID=d.DepID  
    where r.Closed=0 and s.IsSupervis=1
AND s.ag_id=150
    group by s.DepId, s.ag_id,r.fio,d.DName, r.P_ID,d.dep_chief
    order by d.DName,r.fio

  -- новый вариант
  /*select 
    s.DepID, Deps.DName,
    s.ag_id as sv_id, sp.fio as svfam,
    sum(isnull(E.NaklAg,0)) as NaklAg,
    sum(isnull(E.NaklOp,0)) as NaklOp,
    sum(isnull(z.PlanV,0)) as PlanV
  from 
    AgentList ag
    inner join person p on p.p_id=ag.p_id
    inner join Agentlist s on s.ag_id=ag.sv_ag_id
    inner join person sp on sp.p_id=s.p_id
    inner join Deps on Deps.DepID=s.DepId
    left join (
      select distinct dc.ag_id,
      isnull(sum(case when nc.op>=@OP and nc.SP>0 then 1 else 0 end),0) as NaklAg,
      isnull(sum(case when nc.op<@OP  and nc.SP>0 then 1 else 0 end),0) as NaklOp
      from nc inner join defcontract dc on dc.dck=nc.dck
      where nc.nd=@NeedDay 
      group by dc.ag_id  
    )E on E.ag_id=ag.ag_id
    left join (select p.ag_id, count(p.tm) as PlanV from PlanVisit2 p 
               where p.dn=@dn and p.tm<>0 group by p.ag_id) z on z.ag_id=ag.ag_id
    
    left join (select p.ag_id, COUNT(
		case @dn when 1 then p.dt1
        when 2 then p.dt2
        when 3 then p.dt3
        when 4 then p.dt4
        when 5 then p.dt5
        when 6 then p.dt6
        else p.dt7 end) as PlanV from PlanVisit p where p.dt1<>0  group by p.ag_id)Z on z.ag_id=ag.ag_id
    
  where p.Closed=0       
  group by s.DepID,s.ag_id, sp.fio,Deps.DName
  order by s.depid, s.ag_id*/

END