CREATE procedure Guard.PrepareData_Debug @ND datetime
AS
declare @dn smallint
begin   
  Set @dn=datepart(weekday, @ND); -- день недели,1=понедельник

  -- список фактических продаж, выплат и фотографий за день:
  create table #t(ag_id int, tip smallint, dck int, tm varchar(8), AlertTip smallint default 0, SV_AG_ID int default 0, GoodDCK int);
  
  -- втыкаем список продаж за день, сделанных именно агентом:
  insert into #t(ag_id, tip, dck, tm, GoodDCK)
  select nc.ag_id, 1 as tip, nc.dck, nc.TM, nc.dck
    from nc
    where nc.nd=@ND and nc.sp>0 and nc.sp>0 and nc.remarkop not like 'w.%' and nc.op>1000;

  -- и еще список продаж за день, сделанных именно оператором:
  insert into #t(ag_id, tip, dck, tm)
  select nc.ag_id, 0 as tip, nc.dck, nc.TM
    from nc
    where nc.nd=@ND and nc.sp>0 and nc.sp>0 and nc.remarkop not like 'w.%' and nc.op<1000;
  
  -- и список выплат за день, кроме оплат возвратов:
  insert into #t(ag_id, tip, dck, tm, GoodDCK)
  select k.op-1000 as ag_id, 2 as tip, k.dck, min(k.tm), k.dck
    from kassa1 k
    where k.nd=@ND and k.dck>0 and k.op>1000
    and k.Remark not like 'Возврат%'
    and k.Remark not like 'Вычерк%'
    group by k.op-1000, k.dck


  -- а теперь список фотографий:
  insert into #t(ag_id, tip, dck, tm, GoodDCK)
    select p.ag_id, 3 as tip, p.dck, '12:00:00' as tm, p.dck
    from Guard.FMonitor p
    where p.nd=@ND and p.ag_id>0;

  -- Привязываем супервайзеров:
  update #t set sv_ag_id=A.sv_ag_id
  from #t inner join AgentList A on A.ag_id=#t.ag_id;


  -- А вот список запланированных посещений на заданный день, сводка:
  create table #s(ag_id int, PlanV int, sv_ag_id int default 0);
  insert into #s(ag_id, PlanV)
    select p.ag_id, count(ag_id)
    from planvisit2 p
    where ag_id>0 and tm>0 and dn=@dn
    group by ag_id
    order by ag_id;

  -- Еще один список запланированных посещений за день, по покупателям:
  create table #planb(sv_ag_id int, ag_id int, dck int);
  insert into #planb(ag_id, dck)
    select distinct p.ag_id, p.dck
    from planvisit2 p
    where ag_id>0 and tm>0 and dn=@dn;

  -- Привязываем супервайзеров:
  update #s set sv_ag_id=A.sv_ag_id from #s inner join AgentList A on A.ag_id=#s.ag_id;
  update #planb set sv_ag_id=A.sv_ag_id from #planb inner join AgentList A on A.ag_id=#planb.ag_id;

-- SELECT * FROM #PLANB WHERE SV_AG_ID=24;

  -- Последние тревожные сообщения насчет сверок по договорам:
  create table #m(dck int, daid int)  ;
  insert into #m select dck, MAX(daid) daid from DefAlert group by dck;
  create index m_temp_idx on #m(dck);
  create table #AL(dck int, LastSverSVDate datetime, LastSverSVState int);
  insert into #AL
    select #m.dck, da.ND, da.Tip
    from #m inner join defalert DA on DA.daid=#m.daid

  update #t set AlertTip=isnull((select max(#al.LastSverSVState) from #AL where #al.dck=#t.dck),0);

  -- Список закрытых агентов:
  create table #CL(ag_id int);
  insert into #CL select distinct a.ag_id from AgentList a inner join Person P on p.p_id=a.p_id where p.closed=1;

  
  -- *************************************************************************************************
  -- **      Финальный запрос. Какие из агентов попали в тот или другой список:                     **
  -- *************************************************************************************************
  create table #a(ag_id int, sv_ag_id int);
  insert into #a select distinct ag_id,sv_ag_id from #t union select distinct ag_id,sv_ag_id from #s;
  delete from #s where ag_id in (select ag_id from #cl);
  delete from #t where ag_id in (select ag_id from #cl);
  delete from #a where ag_id in (select ag_id from #cl);

update #t set GoodDCK=0;
update #t set #t.GoodDCK=#t.DCK 
  from #t inner join #planb on #planb.dck=#t.dck and #planb.ag_id=#t.ag_id

create table #svod(sv_ag_id int, FactV int, Plata int, Sellag int, Sellop int, Photos int, DCK int);
insert into #svod 
  select 
  #t.sv_ag_id,
  isnull(count(distinct #t.dck),0) as FactV,
  sum(iif(#t.tip=2,1,0)) as Plata,
  sum(iif(#t.tip=1,1,0)) as SellAg,
  sum(iif(#t.tip=0,1,0)) as SellOp,
  sum(iif(#t.tip=3,1,0)) as Photos,
  -- count(distinct #t.DCK) as DCK
  E.DCK
  from 
    #t 
    left join (select ag_id, count(distinct GoodDCK) as DCK from #t where GoodDCK>0 group by ag_id) E on E.ag_id=#t.ag_id
  group by #t.sv_ag_id, E.DCK;

-- select * from #t where sv_ag_id=42;
-- select * from #svod where sv_ag_id=24 order by sv_ag_id;


select * from (    
  select 
    1 as flgMain, sv.depid, deps.dname,  a.sv_ag_id, ps.Fio as SuperFam, a.ag_id, pa.fio, ss.planV, max(#t.AlertTip) AlertTip,
    isnull(count(distinct #t.dck),0) as FactV,
    sum(iif(#t.tip=2,1,0)) as Plata,
    sum(iif(#t.tip=1,1,0)) as SellAg,
    sum(iif(#t.tip=0,1,0)) as SellOp,
    sum(iif(#t.tip=3,1,0)) as Photos,
    E.DCK
  from 
    #a
    left join Agentlist A on A.sv_ag_id=#a.sv_ag_id and A.ag_id=#a.ag_id
    inner join Person PA on PA.p_id=a.p_id
    inner join Agentlist SV on SV.ag_id=A.sv_ag_id
    inner join Person PS on PS.p_id=SV.p_id
    inner join Deps on Deps.DepID=SV.DepID
    left join #t on #t.ag_id=#a.ag_id 
    left join (select ag_id,sum(planv) PlanV from #s group by ag_id) SS on SS.ag_id=#a.ag_id
    left join (select ag_id, count(distinct GoodDCK) as DCK from #t where GoodDCK>0 group by ag_id) E on E.ag_id=#a.ag_id
  where 
    A.sv_ag_id>0 and SV.DepID>0 and pa.Closed=0
  group by sv.depid, deps.dname, a.sv_ag_id, ps.Fio, a.ag_id, pa.fio, ss.planV, E.DCK

union


  select 
    2 as flgMain, sv.depid, deps.dname,  sv.ag_id as SV_AG_ID, PS.Fio as SuperFam, 0 as ag_id, '' as fio, 
    ss.PlanV,  0 as AlertTip,
    sum(tt.FactV) FactV, sum(tt.Plata) Plata, sum(tt.SellAg) SellAg, sum(tt.SellOp) SellOp, sum(tt.Photos) Photos, sum(isnull(tt.DCK,0)) DCK
  from 
    Agentlist SV 
    inner join Person PS on PS.p_id=SV.p_id
    inner join Deps on Deps.DepID=SV.DepID
    left join #svod TT on TT.sv_ag_id=SV.ag_id
    left join (select sv_ag_id, sum(planv) planv from #s group by sv_ag_id) SS on ss.sv_ag_id=sv.ag_id
  where 
    SV.AG_ID in (select distinct sv_ag_id from #a)
    and SV.DepID>0 -- and pa.Closed=0

  --  having 
  --    isnull(count(distinct #t.dck),0)>0
  --    or sum(iif(#t.tip=2,1,0))>0
  --    or sum(iif(#t.tip=1,1,0))>0
  --    or sum(iif(#t.tip=3,1,0))>0
  group by sv.depid, deps.dname,  sv.ag_id, PS.Fio,ss.PlanV
) E
  -- where sv_ag_id=34
  order by flgMain, depid, sv_ag_id

-- select * from #s where sv_ag_id=496;
-- select * from #t where ag_id=24; 
      
   
END