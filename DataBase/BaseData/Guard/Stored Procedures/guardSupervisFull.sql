CREATE PROCEDURE Guard.guardSupervisFull @NeedDay datetime
AS
BEGIN
  declare @OP int
  declare @dn int -- день недели
  set @OP = 1000
  set @dn = datepart(weekday, @NeedDay)

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
    inner join (select distinct sv_ag_id  as NN from agentlist) sv on sv.nn=s.sv_ag_id
    group by s.DepId, s.ag_id,r.fio,d.DName, r.P_ID,d.dep_chief
    order by s.depid, d.DName,r.fio

END