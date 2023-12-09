CREATE procedure Guard.ModCompleteDet @day0 datetime, @day1 DATETIME, @DepID int,
  @kd1 smallint=4, -- массив коэффициентов посещения привязанный к дням недели
  @kd2 smallint=4, @kd3 smallint=4, @kd4 smallint=4, @kd5 smallint=4, @kd6 smallint=4, @kd7 smallint=4
--  @GroupCount int OUT
AS
begin

  -- Список выплат по агентам и покупателей, с указанием времени первой и последней выплаты за день:
  create table #k (nd datetime, ag_id int, b_id int, PlataTime0 smallint, PlataTime1 smallint)

  insert into #k
  select k.nd, op-1000 as Ag_ID, b_id,
    min(dbo.fnMinutesAfterMidnight(cast(k.tm  as datetime))) as Tm0, 
    max(dbo.fnMinutesAfterMidnight(cast(k.tm  as datetime))) as Tm1
  from kassa1 k
  where 
    k.oper=-2 
    and k.op>1000
    and k.nd between @day0 and @day1
  group by k.nd, k.Op, b_id;


  -- Для каждого агента выясняю список запланированных для посещения точек, и сколько раз 
  -- он должен посетить каждую точку
  create table #MP(ag_id int, b_id int, PlanV int) -- план посещений на месяц
  
  insert into #mp
  select  p.ag_id, p.pin, 
    sum(iif(p.dn=1,@kd1,0))+sum(iif(p.dn=2,@kd2,0))+sum(iif(p.dn=3,@kd3,0))+sum(iif(p.dn=4,@kd4,0))
    +sum(iif(p.dn=5,@kd5,0))+sum(iif(p.dn=6,@kd6,0))+sum(iif(p.dn=7,@kd7,0)) as PlanV
  from 
    planvisit2 p
    inner join AgentList a on a.AG_ID=p.ag_id
    inner join Person PR on PR.p_id=a.p_id
    inner join def on def.pin=p.pin
  where 
    pr.Closed=0 and def.Actual=1
  group by p.ag_id, p.pin;

  create index mp_temp_idx on #mp(ag_id,b_id);

  -- Для каждого агента выясняю список его точек и сколько раз посетил он каждую точку за период:
  create table #p (ag_id int, b_id int, Visit smallint, MLID int default 0);

  insert into #p (ag_id, b_id, Visit)
  select ag_id, pin as b_id, sum(visit) as Visit from 
    ( select ag_id, pin, count(distinct needday) as Visit
      from rests where needday between @day0 and @day1 group by ag_id,pin
      -- Кроме того, нужно знать план посещений этого же агента на месяц:
      UNION
      select distinct ag_id, pin, 0 as visit from Planvisit2
    ) E 
  where e.ag_id in (select ag_id from Agentlist where DepID=@DepID)    
  group by ag_id,pin;

select 'Rests' as Comment, * from #p;


  update #p set MLID = p.mlid
  from #p inner join Planvisit2 p on p.ag_id=#p.ag_id and p.pin=#p.b_id
select 'Updated' as Comment, * from #p;

  delete from #p where isnull(mlid,0)=0;
select 'Очищено' as Comment, * from #p;

  -- select * from #p order by ag_id,b_id; -- ДЛЯ ОТЛАДКИ

  -- Теперь детализация. 
  create table #m(ag_id int, b_id int, mlid int, ngrp int, hitag int, Rest decimal(10,1));
  insert into #m(ag_id,b_id,mlid,ngrp,hitag)
  select 
    #p.ag_id, #p.b_id, #p.mlid, nm.ngrp, d.hitag
  from 
    #p
    inner join guard.MatrixList ml on ml.MlID=#p.MLID
    inner join guard.MatrixLDet D on D.mlID=ml.MlID
    inner join nomen nm on nm.hitag=d.hitag
  order by #p.ag_id, #p.b_id, #p.mlid, nm.ngrp;

  -- select 'Table #M' as remark, * from #m where ag_id=580;

  create table #E(ag_id int,pin int,hitag int, rest decimal(10,1));
  insert into #E select ag_id,pin,hitag, avg(qty) as Rest from rests where NeedDay between @day0 and @day1 group by ag_id,pin,hitag;

  -- select 'Table #E' as remark, * from #E where ag_id=580 order by ag_id, pin,hitag;

  update #m set Rest=#E.Rest
  from 
    #m 
    inner join #E on #E.ag_id=#m.ag_id and #e.pin=#m.b_id and #e.hitag=#m.hitag;
  

  -- SELECT 'Update #M' as remark, * from #m where #m.rest is not null and #m.ag_id=580;
  -- SELECT 'Table #P' as remark, * from #p where #p.ag_id=580;

  --   select '#P-->#M' as remark, #p.ag_id, #p.b_id, #m.ngrp, 
  --     sum(iif(isnull(#m.rest,0)=0,0,1)) as Sver
  --   from #p left join #m on #m.ag_id=#p.ag_id and #m.b_id=#p.b_id -- where #p.ag_id=580
  --     group by #p.ag_id, #p.b_id, #m.ngrp

  --  set @GroupCount=(select count(distinct ngrp) from #m);

  select -- 'Final' as remark, 
    sv.depID, Deps.DName, A.sv_ag_id, P2.Fio as SuperFam, #p.ag_id, P.Fio as AgentFam,
    #p.b_id, def.gpName as Buyer,#mp.PlanV,  gr.Ngrp , gr.GrpName, #m.Hitag, nm.Name,
    sum(iif(isnull(#m.rest,0)=0,0,1)) as Sver
  from 
    #p 
    left join #mp on #mp.ag_id=#p.ag_id and #mp.b_id=#p.b_id
    left join #m on #m.ag_id=#p.ag_id and #m.b_id=#p.b_id
    left join Nomen nm on nm.hitag=#m.hitag
    inner join AgentList A on A.ag_id=#p.ag_id
    inner join AgentList SV on SV.ag_id=A.sv_ag_id
    inner join Person P on p.p_id=a.P_ID
    inner join Person P2 on p2.p_id=sv.p_id
    inner join Def on Def.pin=#p.b_id
    inner join Deps on Deps.depid=sv.depid
    inner join GR on Gr.Ngrp=#m.ngrp
    inner join Gr G2 on G2.ngrp=gr.MainParent
  group by 
    sv.depID, Deps.DName, A.sv_ag_id, P2.Fio, #p.ag_id, P.Fio,
    #p.b_id, def.gpName, #mp.PlanV, gr.Ngrp, gr.GrpName,gr.GrpName, #m.Hitag, nm.Name -- gr.MainParent, g2.GrpName


end;