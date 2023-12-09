CREATE procedure Guard.StartFinish @day0 datetime, @day1 DATETIME
as
begin
  -- ******************************************************************************************************************************
  -- ** К списку отделов привязываю супервайзеров, к ним агентов, а к тем уже покупателей.                                       **
  -- ** Покупатели вообще-то связаны с агентами через таблицу контрактов,                                                        **
  -- ** но в данном случае вместо этого буду использовать план посещений.                                                        **
  -- ******************************************************************************************************************************
  create table #p (depid int, sv_id int, ag_id int, b_id int, dck int)
  
  insert into #p(depid, sv_id, ag_id, b_id, dck)
  select 
    distinct sv.depid, ag.sv_ag_id, pv.ag_id, pv.pin, pv.dck
  from
    PlanVisit2 pv
    inner join AgentList ag on ag.AG_ID=pv.ag_id
    inner join Person P on P.p_id=ag.AG_ID
    inner join AgentList sv on sv.AG_ID=ag.sv_ag_id
  where p.Closed=0;

  -- select * from #p;

  -- В этой таблице уникальный ключ - это комбинация кода агента и номера контракта, ag_id и DCK вместе.
  -- select * from #p where b_id=3470 and dck=3469;
  -- select e.cc, count(e.cc) from (select cast(ag_id as varchar(10))+'.'+cast(dck as varchar(10)) as CC from #p) E group by e.cc having count(e.cc)>1;

  -- ******************************************************************************************************************************
  -- ** Это был заголовок, в отчете ему будут соответствовать поля слева, идущие сверху вниз.                                    **  
  -- ** А справа налево - это должны быть данные по всем дням заданного периода. Здесь в процедуре это будет                     **
  -- ** вторая таблица, связанная с первой соотношением master-detail, а кросс-отчет из них я сделаю уже в программе на Delphi.  **
  -- ******************************************************************************************************************************

  create table #F(nd datetime, ag_id int, dck int, tmStart smallint, tmFinish smallint); -- анализируем фотографии

  insert into #F
  select f.nd, f.ag_id, f.dck, min(isnull(fp.SaveTmMn,720)), max(isnull(fp.SaveTmMn,720))
  from 
    guard.FMonitor f
    inner join guard.FMonitorPics fp on fp.fmid=f.fmid
  where f.nd between @day0 and @day1
  group by f.nd, f.ag_id, f.dck;

  -- ******************************************************************************************************************************
  -- ** Список выплат по агентам и покупателям, с указанием времени первой и последней выплаты за день:                          **
  -- ******************************************************************************************************************************
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
    and k.remark not like 'возврат%'
  group by k.nd, k.Op, b_id;


  -- ******************************************************************************************************************************
  -- ** Список продаж по агентам и покупателям, с указанием времени первой и последней продажи за день:                          **
  -- ******************************************************************************************************************************
  create table #s (nd datetime, ag_id int, b_id int, SellTime0 smallint, SellTime1 smallint)

  insert into #s
  select nc.nd, nc.Ag_ID, nc.b_id,
    min(dbo.fnMinutesAfterMidnight(cast(nc.tm  as datetime))) as Tm0, 
    max(dbo.fnMinutesAfterMidnight(cast(nc.tm  as datetime))) as Tm1
  from nc
  where 
    nc.nd>=@day0 and nc.nd<=@day1
    and nc.frizer=0 and nc.tara=0 and nc.actn=0
    and nc.op>1000
    and refdatnom=0 
    and remarkop not like 'w.%'
  group by nc.nd, nc.Ag_ID, nc.b_id;






  -- *********************************************************************************
  -- ** Итоговый запрос:                                                            **
  -- *********************************************************************************
  select e.nd, 
    sv.DepID, Deps.dname,
    a.sv_ag_id as sv_ID, p2.Fio as SuperFam,    
    e.ag_id, p.fio as AgentFam,
/*    dbo.fnMinutes2str(e.PhotoStart) PhotoStart, dbo.fnMinutes2str(e.PhotoFinish) PhotoFinish,*/
/*    dbo.fnMinutes2str(e.PlataTime0) PlataTime0, dbo.fnMinutes2str(e.PlataTime1) PlataTime1,*/
/*    dbo.fnMinutes2str(e.SellTime0)  SellTime0,  dbo.fnMinutes2str(e.SellTime1) SellTime1,*/
    dbo.fnMinutes2str(dbo.fnMin3smallint(e.PhotoStart,e.PlataTime0,e.SellTime0)) as StartTime,
    dbo.fnMinutes2str(dbo.fnMax3smallint(e.PhotoFinish,e.PlataTime1,e.SellTime1)) as FinishTime    
  from (
  select 
    #f.nd, #f.ag_id, 
    min(#f.tmStart) as PhotoStart, max(#f.tmFinish) as PhotoFinish, 
    min(#k.plataTime0) as PlataTime0, max(#k.PlataTime1) as PlataTime1,
    min(#s.SellTime0) as SellTime0, max(#s.SellTime1) as SellTime1
  from 
    #f
    left join #k on #k.nd=#f.nd and #k.ag_id=#f.ag_id
    left join #s on #s.nd=#f.nd and #s.ag_id=#f.ag_id
  group by 
    #f.nd, #f.ag_id
  ) E
  inner join Agentlist A on A.ag_id=e.ag_id
  inner join Person P on P.p_id=a.P_ID
  inner join Agentlist SV on SV.ag_id=a.sv_ag_id
  inner join Person P2 on P2.p_id=sv.P_ID
  inner join Deps on Deps.depid=sv.DepID
  order by     
    e.nd, sv.DepID, a.sv_ag_id, p2.Fio, e.ag_id, p.fio

END