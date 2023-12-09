CREATE procedure Guard.guardAgents @NeedDay datetime
as
declare @op int;
declare @dn tinyint;
begin
  set @op=1000;
  -- Результат работы процедуры ожидается такой: таблица, включающая поля DepID, SV_ID - для привязки к списку отделов и супервайзеров,
  -- поле AG_ID и еще какие-то информационные поля - это что будет показано пользователю в правой части главной формы прогр. Guard.
  -- Исходно связь покупателей, агентов, супервайзеров и отделов установлена в табл. Def,Defcontract,AgentList.
  -- Но есть еще дополнительная привязка, записанная в плане посещений PlanVisit2.
  -- Вообще-то возможны посещения покупателей, которых нет ни в Def-Defcontract-AgentList, ни в PlanVisit2, но это пока пропустим.

  set @dn=datepart(weekday,@NeedDay);

  create table #Rez(DepID smallint, sv_id int, ag_id int, PlanV int default 0, NaklAg int default 0, NaklOp int default 0, 
    KolVyp int, DSA varchar(15));
  -- Сейчас в #Rez будет записана исходная связь агенты-супервайзеры-отделы:
  insert into #Rez(depid,sv_id,ag_id)
    select distinct s.depid, a.sv_ag_id, dc.ag_id
    from DefContract dc
    inner join AgentList a on a.AG_ID=dc.ag_id
    inner join Agentlist S on S.ag_id=a.sv_ag_id
  order by s.depid, a.sv_ag_id, dc.ag_id;
  update #REZ set DSA=cast(Depid as varchar)+'.'+cast(SV_ID as varchar)+'.'+cast(ag_id as varchar);
--  select * from #rez order by depid, sv_id, ag_id;
--  select * from #rez where sv_id=150 order by depid, sv_id, ag_id;

  -- Теперь вычислим аналогичную связь, но только исходя из таблицы посещений:
  create table #P(DepID smallint, sv_id int, ag_id int, PlanV int default 0, DSA varchar(15));
  insert into #p(depid,sv_id,ag_id,PlanV)
    select s.depid, a.sv_ag_id, p.ag_id, count(p.pin)
    from 
      Planvisit2 p
      inner join Agentlist a on a.ag_id=p.ag_id
      inner join Agentlist S on S.ag_id=a.sv_ag_id
    where p.dn=@dn
    group by s.depid, a.sv_ag_id, p.ag_id;
  update #P set DSA=cast(Depid as varchar)+'.'+cast(SV_ID as varchar)+'.'+cast(ag_id as varchar);
--  select * from #p order by depid, sv_id, ag_id;
--  select * from #p where sv_id=150 order by depid, sv_id, ag_id;
  update #REZ set Planv=#p.Planv from #Rez inner join #p on #p.dsa=#rez.dsa;

  insert into #rez(depid,sv_id,ag_id,PlanV,dsa)
    select depid,sv_id,ag_id,PlanV,dsa from #p where #p.dsa not in (select dsa from #rez);

  -- Какие были продажи агентами и операторами за заданный день?
  -- Возможны варианты. Что, если на одного покупателя пробили две-три накладные?
  -- Можно считать их всесте за одну большую накладную, а можно за две-три разных.
  
  update #Rez set NaklAg=E.NaklAg
  from (
    select ag_id,  count(distinct nc.dck) as NaklAg --count(datnom) as NaklAg -- 
    from nc 
    where nd=@NeedDay and SP>0 and Op>=@OP and nc.RemarkOp not like 'w.%'
    group by ag_id
    ) E
    where E.ag_id=#Rez.ag_id;

  update #Rez set NaklOp=E.NaklOp
  from (
    select ag_id,  count(distinct nc.dck) as NaklOp -- count(datnom) as NaklOp --
    from nc 
    where nd=@NeedDay and SP>0 and Op<@OP and nc.RemarkOp not like 'w.%'
    group by ag_id
    ) E
    where E.ag_id=#Rez.ag_id;

-- Какие были выплаты за день, не считая оплат возвратов и вычерков?
  update #rez set KolVyp=E.KolVyp
  from (
     select a.ag_id, COUNT(distinct k.dck) as KolVyp 
     from Kassa1 k inner join AgentList a on a.NomerOP=k.Op
     where k.nd=@NeedDay and k.oper=-2 and k.plata>0 and k.Remark not like 'Вычерк%' and k.Remark not like 'Возврат%'
     group by a.ag_id) E
  where E.ag_id=#rez.ag_id;

  -- Последние тревожные сообщения насчет сверок по договорам:
  create table #m(dck int, daid int)  ;
  insert into #m select dck, MAX(daid) daid from DefAlert group by dck;
  create index m_temp_idx on #m(dck);

  -- Количество сверок агентами. Назовем это инвентаризацией:
  create table #a(ag_id int, KolInvent int);
  insert into #a 
    select r.ag_id, COUNT(distinct r.pin) as KolInvent
    from Rests r inner join Agentlist A on A.ag_id=r.ag_id and a.sv_ag_id>0 and a.sv_ag_id<>a.ag_id
    where r.NeedDay=@NeedDay
    group by r.ag_id;

  -- Теперь количество сверок супервайзерами. Это будет называться аудит.
  -- Считать буду так: это сверка для покупателя, которую выполнил не назначенный
  -- этому покупателю агент, а супервайзер этого агента.
  create table #s(ag_id int, KolAudit int);
  insert into #s
    select dc.ag_id, count(distinct r.pin) as KolAudit -- r.ag_id as Sv_ID, r.dck, dc.ag_id, r.pin
    from rests r inner join defcontract dc on dc.dck=r.dck
    where 
      dateadd(day, datediff(day,0,r.nd),0)=@NeedDay
      and r.ag_id<>dc.ag_id
    group by dc.ag_id;


  -- Чтение результата:
  select #rez.*, p.Fio, E.AlertTip, #a.KolInvent, #s.kolaudit
  from #rez 
  left join (
    select dc.ag_id, max(da.Tip) as AlertTip 
    from #m 
      inner join DefAlert da on da.DaID=#m.daid
      inner join defcontract dc on dc.dck=da.dck 
    group by dc.ag_id
    ) E on E.ag_id=#rez.ag_id
  left join #s on #s.ag_id=#rez.ag_id
  left join #a on #a.ag_id=#rez.ag_id
  inner join agentlist a on a.AG_ID=#rez.ag_id
  inner join Person P on P.p_id=a.p_id
  -- where #rez.sv_id=30 
  order by #rez.depid, #rez.sv_id, #rez.ag_id

  

/*
  
  
-- Количество сверок агентами. Назовем это инвентаризацией:
  create table #a(ag_id int, KolInvent int);
  insert into #a 
  select r.ag_id, COUNT(distinct r.pin) as KolInvent
  from Rests r inner join Agentlist A on A.ag_id=r.ag_id and a.sv_ag_id>0 and a.sv_ag_id<>a.ag_id
  where dateadd(day, datediff(day,0,r.nd),0)=@NeedDay
  group by r.ag_id;

  -- Теперь количество сверок супервайзерами. Это будет называться аудит.
  -- Считать буду так: это сверка для покупателя, которую выполнил не назначенный
  -- этому покупателю агент, а супервайзер этого агента.
  create table #s(ag_id int, KolAudit int);
  insert into #s
    select dc.ag_id, count(distinct r.pin) as KolAudit -- r.ag_id as Sv_ID, r.dck, dc.ag_id, r.pin
    from rests r inner join defcontract dc on dc.dck=r.dck
    where 
      dateadd(day, datediff(day,0,r.nd),0)=@NeedDay
      and r.ag_id<>dc.ag_id
    group by dc.ag_id;

  -- План посещений:
  create table #pos(depid smallint, sv_ag_id int, ag_id int, Kol int);
  insert into #pos
    select 
      a.depid, a.sv_ag_id, a.AG_ID, count(p.pin) as PlanCount
    from 
      planvisit2 p 
      inner join Agentlist a on a.ag_id=p.ag_id 
    where p.dn=@dn  
    group by a.depid, a.sv_ag_id, a.AG_ID
    order by a.depid, a.sv_ag_id, a.AG_ID;
  select * from #pos where sv_ag_id=150;
  
  select a.ag_id, p.fio, a.sv_ag_id as sv_id,
    (select COUNT(distinct t.dck) from NC t where t.ag_id=a.ag_id and t.op>=@OP and t.sp>0 and t.ND=@NeedDay) as NaklAg,
    (select COUNT(distinct t.dck) from NC t where t.ag_id=a.ag_id and t.op<@OP and t.sp>0 and t.ND=@NeedDay) as NaklOp,
    -- (select COUNT(p.pin) from PlanVisit2 p where p.dn=@dn and p.ag_id=a.ag_id and p.pin>0) as PlanV,
    #pos.kol as PlanV,
    (select COUNT(distinct k.dck) from Kassa1 k, AgentList ag where k.nd=@NeedDay and k.oper=-2 and k.Op=ag.NomerOP and ag.ag_id=a.ag_id) as KolVyp,
--    (select COUNT(distinct r.pin) from Rests r where r.nd>=@NeedDay and r.nd < dateadd(day,1,@NeedDay) and r.ag_id=a.ag_id) as kolAudit,
--    (select COUNT(distinct ao.pin) from AdvOrder ao where ao.nd=@NeedDay and ao.ag_id=a.ag_id) as kolAdvOrd,
--    (select case when isnull((select count(*) from AdvOrder ao where ao.[date]=@NeedDay and ao.pin in
--      (select p.pin from planvisit p where p.ag_id=a.ag_id union select d.pin from def d where d.brag_id=a.ag_id)),0)>0 then 1 else 0 end) as AdvOrdTod,
--    (select case when isnull((select count(*) from AdvOrder ao where ao.[date]=@NeedDay and ao.pin in
--      (select p.pin from planvisit p where p.ag_id=a.ag_id union select d.pin from def d where d.brag_id=a.ag_id)),0)>0 then 1 else 0 end) as AdvOrdTom,
    #a.KolInvent as KolInvent,
    #s.KolAudit as KolAudit,
    0.00 as Debt, 0.00 as Overdue,
    E.AlertTip
from 
  
  AgentList a 
  left join Person p on a.p_id=p.p_id
  left join #a on #a.ag_id=a.ag_id
  left join #s on #s.ag_id=a.ag_id
  left join #pos on #pos.Depid=a.DepId and #pos.sv_ag_id=a.sv_ag_id and #pos.AG_ID=a.ag_id
  left join (
    select dc.ag_id, max(da.Tip) as AlertTip 
    from #m 
      inner join DefAlert da on da.DaID=#m.daid
      inner join defcontract dc on dc.dck=da.dck 
    group by dc.ag_id
    ) E on E.ag_id=a.ag_id
where p.Closed=0 and sv_id=150
order by sv_id, p.fio

*/
  
-- *********************************************************************************************************************************************************   
  
 /* 
  
  create table #t(ag_id int, 
    NaklAg int default 0, NaklOp int default 0, PlanV int default 0,
    KolVyp int default 0,  kolAudit int default 0,
    kolAdvOrd int default 0, AdvOrdTod int default 0,  AdvOrdTom int default 0);

  insert into #t(ag_id, naklag, naklop)
  select dc.ag_id,
      isnull(sum(case when nc.op>=@OP and nc.SP>0 then 1 else 0 end),0) as NaklAg,
      isnull(sum(case when nc.op<@OP  and nc.SP>0 then 1 else 0 end),0) as NaklOp
  from dbo.nc  nc inner join dbo.defcontract dc on dc.dck=nc.dck
  where nc.nd=@nd 
  group by dc.ag_id ;


  insert into #t(ag_id, PlanV)
  select 
    p.ag_id, 
    COUNT(case @dow when 1 then p.dt1
      when 2 then p.dt2
      when 3 then p.dt3
      when 4 then p.dt4
      when 5 then p.dt5
      when 6 then p.dt6
      else p.dt7 end) as PlanV 
  from dbo.PlanVisit p 
  where p.dt1<>0  
  group by p.ag_id;

  insert into #t(ag_id, KolVyp)
  select 
    ag.AG_ID, COUNT(distinct k.dck) as Kolvyp
  from dbo.Kassa1 k inner join dbo.AgentList ag on k.Op=ag.NomerOp and k.oper=-2 
  where 
    k.nd>=@nd 
  group by ag.AG_ID;

  insert into #t(ag_id, KolAdvOrd)
  select
    ao.ag_id, count(distinct ao.pin) as KolAdvOrd
  from
    dbo.advOrder ao
    inner join dbo.AgentList ag on ag.ag_id=ao.ag_id
  where ao.nd>=@nd
  group by ao.ag_id;



  select ag_id, sum(NaklAg) NaklAg, sum(NaklOp) NaklOp, 
    sum(PlanV) PlanV,
    sum(KolVyp) Kolvyp,
    sum(Kolaudit) KolAudit,
    sum(kolAdvOrd) kolAdvOrd,
    sum(AdvOrdTod) AdvOrdTod,
    sum(AdvOrdTom) AdvOrdTom
  from #t 
  where ag_id>0
  group by ag_id;*/
  
  
end;

  --=================================================================================
/*
  select datepart(weekday, getdate())    
    
  select a.ag_id,p.fio as fam,a.sv_ag_id as sv_id,
  (select COUNT(distinct t.dck) from NC t where t.ag_id=a.ag_id and t.op>=1000 and t.sp>0 and t.nd=@nd) as NaklAg,
  (select COUNT(distinct t.dck) from NC t where t.ag_id=a.ag_id and t.op<1000 and t.sp>0 and t.nd=@nd) as NaklOp,
  (select COUNT(p.dt4) from PlanVisit p where p.dt4<>0 and p.ag_id=a.ag_id) as PlanV,
  (select COUNT(distinct k.dck) from Kassa1 k, AgentList ag where k.nd>=@nd and k.oper=-2 and k.Op=ag.NomerOp and ag.ag_id=a.ag_id) as KolVyp,
  (select COUNT(distinct r.pin) from Rests r where r.nd>=@nd and r.ag_id=a.ag_id) as kolAudit,
  (select COUNT(distinct ao.pin) from AdvOrder ao where ao.nd>=@nd and ao.ag_id=a.ag_id) as kolAdvOrd,
  (select case when isnull((select count(*) from AdvOrder ao where ao.[date]>@nd and ao.pin in
  (select p.pin from planvisit p where p.ag_id=a.ag_id union select d.pin from def d where d.brag_id=a.ag_id)),0)>0 then 1 else 0 end) as AdvOrdTom
  from Agentlist a left join Person p on a.p_id=p.p_id where p.Closed=0
*/