CREATE procedure FMonitorCalc @day0 datetime, @day1 datetime
as
begin
  declare @day1a datetime
  set @day1a=dateadd(DAY,1,@day1)
  
  -- ТАБЛИЦА КОЛИЧЕСТВА ФОТОГРАФИЙ, РАЗБИТЫХ ПО КАТЕГОРИЯМ:
  create table #F(dck int default 0, p1 int default 0, p2 int default 0, 
    p3 int default 0, p4 int default 0, p5 int default 0, p6 int default 0);
  
  -- ВСЕ ОТДЕЛЫ ПРОДАЖ, КРОМЕ БЕЗЫМЯННОГО, БИК И СЕТЕВОГО:
  insert into #f(dck, p1)
  select F.DCK, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join defcontract dc on dc.dck=f.dck
    inner join AgentList a on a.ag_id=dc.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report='к'
  group by F.DCK;

  insert into #f(dck, p2)
  select F.DCK, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join defcontract dc on dc.dck=f.dck
    inner join AgentList a on a.ag_id=dc.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report='н'
  group by F.DCK;

  insert into #f(dck, p3)
  select F.DCK, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join defcontract dc on dc.dck=f.dck
    inner join AgentList a on a.ag_id=dc.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report='ок'
  group by F.DCK;

  insert into #f(dck, p4)
  select F.DCK, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join defcontract dc on dc.dck=f.dck
    inner join AgentList a on a.ag_id=dc.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report='л'
  group by F.DCK;

  insert into #f(dck, p5)
  select F.DCK, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join defcontract dc on dc.dck=f.dck
    inner join AgentList a on a.ag_id=dc.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report='и'
  group by F.DCK;

  insert into #f(dck, p6)
  select F.DCK, count(p.mpid) as p1
  from 
    FMonitor F 
    inner join FMonitorPics P on P.FMID=F.FMID 
    inner join defcontract dc on dc.dck=f.dck
    inner join AgentList a on a.ag_id=dc.ag_id
    inner join Deps on Deps.depid=a.depid
  where F.SaveDay>=@day0 and F.SaveDay<@Day1a
  and deps.sale=1 and deps.DepID not in (0,3,4) 
  and F.report not in ('к','н','ок','л','и')
  group by F.DCK;

  -- ОТДЕЛ ПРОДАЖ БИК, №4:
  insert into #f(dck, p1)
    select F.DCK, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join defcontract dc on dc.dck=f.dck
      inner join AgentList a on a.ag_id=dc.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=4
    and F.report='д'
    group by F.DCK;
  insert into #f(dck, p2)
    select F.DCK, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join defcontract dc on dc.dck=f.dck
      inner join AgentList a on a.ag_id=dc.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=4
    and F.report='м'
    group by F.DCK;
  insert into #f(dck, p3)
    select F.DCK, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join defcontract dc on dc.dck=f.dck
      inner join AgentList a on a.ag_id=dc.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=4
    and F.report='б'
    group by F.DCK;
  insert into #f(dck, p4)
    select F.DCK, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join defcontract dc on dc.dck=f.dck
      inner join AgentList a on a.ag_id=dc.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=4
    and F.report='к'
    group by F.DCK;
  insert into #f(dck, p5)
    select F.DCK, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join defcontract dc on dc.dck=f.dck
      inner join AgentList a on a.ag_id=dc.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=4
    and F.report='и'
    group by F.DCK;
  insert into #f(dck, p6)
    select F.DCK, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join defcontract dc on dc.dck=f.dck
      inner join AgentList a on a.ag_id=dc.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=4
    and F.report not in ('д','м','б','и','к')
    group by F.DCK;

  -- ОТДЕЛ ПРОДАЖ СЕТЕВОЙ, №3:
  insert into #f(dck, p1)
    select F.DCK, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join defcontract dc on dc.dck=f.dck
      inner join AgentList a on a.ag_id=dc.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=3
    and F.report='1'
    group by F.DCK;
  insert into #f(dck, p2)
    select F.DCK, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join defcontract dc on dc.dck=f.dck
      inner join AgentList a on a.ag_id=dc.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=3
    and F.report='2'
    group by F.DCK;
  insert into #f(dck, p3)
    select F.DCK, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join defcontract dc on dc.dck=f.dck
      inner join AgentList a on a.ag_id=dc.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=3
    and F.report='3'
    group by F.DCK;
  insert into #f(dck, p6)
    select F.DCK, count(p.mpid) as p1
    from 
      FMonitor F 
      inner join FMonitorPics P on P.FMID=F.FMID 
      inner join defcontract dc on dc.dck=f.dck
      inner join AgentList a on a.ag_id=dc.ag_id
      inner join Deps on Deps.depid=a.depid
    where F.SaveDay>=@day0 and F.SaveDay<@Day1a
    and deps.DepID=3
    and F.report not in ('1','2','3')
    group by F.DCK;


  select a.sv_ag_id as sv_id, a.ag_id, dc.pin, def.gpName,
    e.cnt1,e.cnt2,e.cnt3,e.cnt4,e.cnt5,e.cnt6,e.cnt7, FF.FrizCnt, 
    PP.P1,PP.P2,PP.P3,PP.P4,PP.P5,pp.p6
  from
    agentlist a
    inner join defcontract dc on dc.ag_id=a.ag_id
    inner join def on def.pin=dc.pin
    left join ( select
      p.pin, p.ag_id,
      sum(iif(p.dt1=0,0,1)) as Cnt1,
      sum(iif(p.dt2=0,0,1)) as Cnt2,
      sum(iif(p.dt3=0,0,1)) as Cnt3,
      sum(iif(p.dt4=0,0,1)) as Cnt4,
      sum(iif(p.dt5=0,0,1)) as Cnt5,
      sum(iif(p.dt6=0,0,1)) as Cnt6,
      sum(iif(p.dt7=0,0,1)) as Cnt7
      from PlanVisit p
      group by p.pin, p.ag_id
      )E on E.pin=dc.pin and e.ag_id=dc.ag_id
    left join (select F.dck, count(f.dck) as FrizCnt from Frizer F  where F.Tip=0 group by F.DCK) FF on FF.dck=dc.dck
    left join (
      select dck, sum(p1) p1,sum(p2) p2,sum(p3) p3,sum(p4) p4,sum(p5) p5,sum(p6) p6
      from #F
      group by Dck) PP on PP.dck=dc.dck
  where
    a.sv_ag_id>0 and a.ag_id>0
    and Def.gpname is not null
    and Def.gpname<>''
    and a.depid not in (0,17,38,5,8,6,41,26)
  order by a.sv_ag_id, a.ag_id, def.gpname
  
end;