CREATE procedure FMonitorCalc2_dEBUG @day0 datetime, @day1 datetime
as
begin
  declare @day1a datetime
  set @day1a=dateadd(DAY,1,@day1)
  
  -- ТАБЛИЦА КОЛИЧЕСТВА ФОТОГРАФИЙ, РАЗБИТЫХ ПО КАТЕГОРИЯМ:
  create table #F(pin int default 0, ag_id int,  p1 int default 0, p2 int default 0, 
    p3 int default 0, p4 int default 0, p5 int default 0, p6 int default 0);
  
  -- ВСЕ ОТДЕЛЫ ПРОДАЖ, КРОМЕ БЕЗЫМЯННОГО, БИК И СЕТЕВОГО:

  insert into #f(pin, ag_id, p1)
  select DC.pin, f.ag_id, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join Defcontract dc on dc.dck=f.dck
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join AgentList a on a.ag_id=f.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report='к'
  group by DC.pin,f.ag_id;

  insert into #f(pin, ag_id, p2)
  select DC.pin, f.ag_id, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join Defcontract dc on dc.dck=f.dck
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join AgentList a on a.ag_id=f.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report='н'
  group by DC.pin,f.ag_id;
  
  insert into #f(pin, ag_id, p3)
  select DC.pin, f.ag_id, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join Defcontract dc on dc.dck=f.dck
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join AgentList a on a.ag_id=f.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report='ок'
  group by DC.pin,f.ag_id;

  insert into #f(pin, ag_id, p4)
  select DC.pin, f.ag_id, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join Defcontract dc on dc.dck=f.dck
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join AgentList a on a.ag_id=f.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report='л'
  group by DC.pin,f.ag_id;

  insert into #f(pin, ag_id, p5)
  select DC.pin, f.ag_id, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join Defcontract dc on dc.dck=f.dck
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join AgentList a on a.ag_id=f.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report='и'
  group by DC.pin,f.ag_id;

  insert into #f(pin, ag_id, p6)
  select DC.pin, f.ag_id, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join Defcontract dc on dc.dck=f.dck
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join AgentList a on a.ag_id=f.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report not in ('к','н','ок','л','и')
  group by DC.pin,f.ag_id;


  -- ОТДЕЛ ПРОДАЖ БИК, №4:
  insert into #f(pin, ag_id, p1)
  select DC.pin, f.ag_id, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join Defcontract dc on dc.dck=f.dck
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join AgentList a on a.ag_id=f.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.DepID=4
  and F.report='д'
  group by DC.pin,f.ag_id;
    
  insert into #f(pin, ag_id,p2)
  select DC.pin, f.ag_id, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join Defcontract dc on dc.dck=f.dck
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join AgentList a on a.ag_id=f.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.DepID=4
  and F.report='м'
  group by DC.pin,f.ag_id;
    
  insert into #f(pin, ag_id, p3)
    select DC.pin, f.ag_id, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join Defcontract dc on dc.dck=f.dck
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join AgentList a on a.ag_id=f.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=4
    and F.report='б'
    group by DC.pin,f.ag_id;
    
  insert into #f(pin, ag_id, p4)
    select DC.pin, f.ag_id, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join Defcontract dc on dc.dck=f.dck
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join AgentList a on a.ag_id=f.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=4
    and F.report='к'
    group by DC.pin,f.ag_id;
    
  insert into #f(pin, ag_id, p5)
    select DC.pin, f.ag_id, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join Defcontract dc on dc.dck=f.dck
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join AgentList a on a.ag_id=f.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=4
    and F.report='и'
    group by DC.pin,f.ag_id;
    
  insert into #f(pin, ag_id, p6)
    select DC.pin, f.ag_id, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join Defcontract dc on dc.dck=f.dck
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join AgentList a on a.ag_id=f.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=4
    and F.report not in ('д','м','б','и','к')
    group by DC.pin,f.ag_id;

  -- ОТДЕЛ ПРОДАЖ СЕТЕВОЙ, №3:

  insert into #f(pin, ag_id, p1)
    select DC.pin, f.ag_id, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join Defcontract dc on dc.dck=f.dck
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join AgentList a on a.ag_id=f.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=3
    and F.report='1'
    group by DC.pin,f.ag_id;
    
  insert into #f(pin, ag_id, p2)
    select DC.pin, f.ag_id, count(p.mpid) as p2
    from 
      FMonitor F 
      inner join Defcontract dc on dc.dck=f.dck
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join AgentList a on a.ag_id=f.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=3
    and F.report='2'
    group by DC.pin,f.ag_id;
    
  insert into #f(pin, ag_id, p3)
    select DC.pin, f.ag_id, count(p.mpid) as p3
    from 
      FMonitor F 
      inner join Defcontract dc on dc.dck=f.dck
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join AgentList a on a.ag_id=f.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=3
    and F.report='3'
    group by DC.pin,f.ag_id;
    
  insert into #f(pin, ag_id, p6)
    select DC.pin, f.ag_id, count(p.mpid) as p6
    from 
      FMonitor F 
      inner join Defcontract dc on dc.dck=f.dck
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join AgentList a on a.ag_id=f.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=3
    and (F.report is null or F.report not in ('1','2','3'))
    group by DC.pin,f.ag_id;


  -- Сооружаю из Planvisit2 более широкую таблицу:
  create table #w(pin int, dck int, ag_id int, Cnt1 int, Cnt2 int, Cnt3 int, Cnt4 int, 
    Cnt5 int, Cnt6 int, Cnt7 int)
  insert into #w
  select
    p.pin,p.dck,p.ag_id,
    SUM(iif(p.dn=1,iif(p.tm=0,0,1),0)) as Cnt1,
    SUM(iif(p.dn=2,iif(p.tm=0,0,1),0)) as Cnt2,
    SUM(iif(p.dn=3,iif(p.tm=0,0,1),0)) as Cnt3,
    SUM(iif(p.dn=4,iif(p.tm=0,0,1),0)) as Cnt4,
    SUM(iif(p.dn=5,iif(p.tm=0,0,1),0)) as Cnt5,
    SUM(iif(p.dn=6,iif(p.tm=0,0,1),0)) as Cnt6,
    SUM(iif(p.dn=7,iif(p.tm=0,0,1),0)) as Cnt7
  from
    PlanVisit2 p
    inner join AgentList A on A.ag_id=p.ag_id
    inner join Person PS on PS.p_id=A.p_id
  where
    PS.Closed=0
  group by p.pin,p.dck,p.ag_id
  order by p.pin  
  

  select #W.DCK,a.sv_ag_id as sv_id, #w.ag_id, #w.pin, def.gpName,
    #w.cnt1,#w.cnt2,#w.cnt3,#w.cnt4,#w.cnt5,#w.cnt6,#w.cnt7, FF.FrizCnt, 
    PP.P1,PP.P2,PP.P3,PP.P4,PP.P5,pp.p6
  from
    #w
    inner join agentlist a on a.ag_id=#w.ag_id
    inner join def on def.pin=#w.pin
    left join (select F.dck, count(f.dck) as FrizCnt from Frizer F  where F.Tip=0 group by F.DCK) FF on FF.dck=#w.dck
    left join (
      select pin, ag_id, sum(isnull(p1,0)) p1,sum(isnull(p2,0)) p2,sum(isnull(p3,0)) p3,sum(isnull(p4,0)) p4,sum(isnull(p5,0)) p5,sum(isnull(p6,0)) p6
      from #F
      group by pin,ag_id) PP on PP.pin=#w.pin and PP.ag_id=#w.ag_id
  where
    a.sv_ag_id>0 and a.ag_id>0
    and Def.gpname is not null
    and Def.gpname<>''
    and a.depid not in (0,17,38,5,8,6,41,26)
    AND #W.PIN IN (85,41325)
  order by a.sv_ag_id, #w.ag_id, def.gpname

end;