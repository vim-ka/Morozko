CREATE procedure dbo.FMonitorCalc3 @day0 datetime, @day1 datetime
as
begin

  -- Таблица посещений. Сооружаю из Planvisit2 более широкую таблицу:
  create table #w(pin int, dck int, ag_id int, Cnt1 int default 0, 
    Cnt2 int default 0, Cnt3 int default 0, Cnt4 int default 0, 
    Cnt5 int default 0, Cnt6 int default 0, Cnt7 int default 0)
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
    PS.Closed=0 and p.pin>0
  group by p.pin,p.dck,p.ag_id
  order by p.pin  
    
  -- Раcпределяем снимки по отделам, супервайзерам, агентам, покупателям и примечаниям:
  create table #t(DepID int, sv_ag_id int, AG_ID int, Pin int,  
    P1 int,P2 int, P3 int, P4 int, P5 int, P6 int, P7 int, p8 int, p9 int, p10 int, p11 int, p12 int, p13 int, p14 int, p15 int, p16 int);

  insert into #t(DepID, sv_ag_id, AG_ID, Pin, P1, P2, P3, P4, P5, P6, P7, p8,p9,p10,p11,p12,p13,p14,p15,p16)
    select 
      S.DepID, A.sv_ag_id, F.AG_ID, DC.Pin, 
      sum(iif(P.Grp=1,1,0)) as P1,
      sum(iif(P.Grp=2,1,0)) as P2,
      sum(iif(P.Grp=3,1,0)) as P3,
      sum(iif(P.Grp=4,1,0)) as P4,
      sum(iif(P.Grp=5,1,0)) as P5,
      sum(iif(P.Grp=6,1,0)) as P6,
      sum(iif(P.Grp=7,1,0)) as P7,
      sum(iif(P.Grp=8,1,0)) as P8,
      sum(iif(P.Grp=9,1,0)) as P9,
      sum(iif(P.Grp=10,1,0)) as P10,
      sum(iif(P.Grp=11,1,0)) as P11,
      sum(iif(P.Grp=12,1,0)) as P12,
      sum(iif(P.Grp=13,1,0)) as P13,
      sum(iif(P.Grp=14,1,0)) as P14,
      sum(iif(P.Grp=15,1,0)) as P15,
      sum(iif(P.Grp=16,1,0)) as P16
    from 
      Guard.FMonitor F
      inner join Guard.FMonitorPics P on P.fmid=F.fmid
      inner join Defcontract DC on DC.DCK=F.DCK
      inner join AgentList A on A.ag_id=F.AG_ID
      inner join AgentList S on S.ag_ID=A.sv_ag_id
    where 
      F.nd between @day0 and @day1
--      and dc.pin=33491
    group by 
      S.DepID, A.sv_ag_id, F.AG_ID, DC.Pin;

  declare @TruePicCount int;
  set @TruePicCount=(select sum(p1+p2+p3+p4+p5+p6+p7) from #t);
  print 'Количество найденных картинок в базе данных: '+cast(@TruePicCount as varchar)



  insert into #w(pin, dck, ag_id) 
    select pin,0 as dck,ag_id from #t where sv_ag_id=278 or ag_id in (57,234);

  -- Дописываю покупателей, сфотографированных сверх плана:
  insert into #w(pin,dck, ag_id)
  select distinct #t.pin, dc.dck, dc.ag_id
  from #t inner join defcontract dc on dc.pin=#t.pin 
  where #t.pin not in (select pin from #w);

select sv_id,ag_id,pin,gpname, cnt1, cnt2, cnt3, cnt4, cnt5, cnt6, cnt7, FrizCNT,
  p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16
  from (
  select a.sv_ag_id as sv_id, #w.ag_id, #w.pin, def.gpName,
    #w.cnt1,#w.cnt2,#w.cnt3,#w.cnt4,#w.cnt5,#w.cnt6,#w.cnt7, 
    isnull(FF.FrizCnt,0) FrizCNT,
    isnull(#t.p1,0) p1,
    isnull(#t.p2,0) p2,
    isnull(#t.p3,0) p3,
    isnull(#t.p4,0) p4,
    isnull(#t.p5,0) p5,
    isnull(#t.p6,0) p6,
    isnull(#t.p7,0) p7,
    isnull(#t.p8,0) p8,
    isnull(#t.p9,0) p9,
    isnull(#t.p10,0) p10,
    isnull(#t.p11,0) p11,
    isnull(#t.p12,0) p12,
    isnull(#t.p13,0) p13,
    isnull(#t.p14,0) p14,
    isnull(#t.p15,0) p15,
    isnull(#t.p16,0) p16
  from
    #w
    left join agentlist a on a.ag_id=#w.ag_id
    left join def on def.pin=#w.pin
    left join #t on #t.sv_ag_id=a.sv_ag_id and #t.ag_id=#w.ag_id and #t.pin=#w.pin  
    left join (select F.dck, count(f.dck) as FrizCnt from Frizer F  where F.Tip=0 group by F.DCK) FF on FF.dck=#w.dck
  )E 
  where 
    cnt1+cnt2+cnt3+cnt4+cnt5+cnt6+cnt7<>0
    or p1+p2+p3+p4+p5+p6+p7+p8+p9+p10+p11+p12+p13+p14+p15+p16<>0
    or FrizCNT<>0
  order by sv_id,ag_id,pin  
end;

/*


  -- Для каждой строки в списке снимков определяем категорию снимка, число от 1 до 6:
  update #t set Col=dbo.fnDepPicRemGrp(#t.depid,#t.rm);

  -- Заново распределяем таблицу по шести категориям:
  
--   select * from #t where #t.ag_id not in (select ag_id from #w);
--   select sum(PicCount) PicCount from #t where #t.ag_id not in (select ag_id from #w);
  
  
  select a.sv_ag_id as sv_id, #w.ag_id, #w.pin, def.gpName,
    #w.cnt1,#w.cnt2,#w.cnt3,#w.cnt4,#w.cnt5,#w.cnt6,#w.cnt7, FF.FrizCnt, 
    sum(iif(col=1, PicCount, 0)) as P1,
    sum(iif(col=2, PicCount, 0)) as P2,
    sum(iif(col=3, PicCount, 0)) as P3,
    sum(iif(col=4, PicCount, 0)) as P4,
    sum(iif(col=5, PicCount, 0)) as P5,
    sum(iif(col=6, PicCount, 0)) as P6
  from
    #w
    left join agentlist a on a.ag_id=#w.ag_id
    left join def on def.pin=#w.pin
    left join #t on #t.sv_ag_id=a.sv_ag_id and #t.ag_id=#w.ag_id and #t.pin=#w.pin  
    left join (select F.dck, count(f.dck) as FrizCnt from Frizer F  where F.Tip=0 group by F.DCK) FF on FF.dck=#w.dck
    --  where a.sv_ag_id=322 and #w.ag_id=368
  group by a.sv_ag_id, #w.ag_id, #w.pin, def.gpName,
    #w.cnt1,#w.cnt2,#w.cnt3,#w.cnt4,#w.cnt5,#w.cnt6,#w.cnt7, FF.FrizCnt




  
  declare @UsedPicCount int;
  set @UsedPicCount = (
  select sum(isnull(p1,0)+isnull(p2,0)+isnull(p3,0)+isnull(p4,0)+isnull(p5,0)+isnull(p6,0)) from
( 
  select a.sv_ag_id as sv_id, #w.ag_id, #w.pin, def.gpName,
    #w.cnt1,#w.cnt2,#w.cnt3,#w.cnt4,#w.cnt5,#w.cnt6,#w.cnt7, FF.FrizCnt, 
    sum(iif(col=1, PicCount, null)) as P1,
    sum(iif(col=2, PicCount, null)) as P2,
    sum(iif(col=3, PicCount, null)) as P3,
    sum(iif(col=4, PicCount, null)) as P4,
    sum(iif(col=5, PicCount, null)) as P5,
    sum(iif(col=6, PicCount, null)) as P6
  from
    #w
    left join agentlist a on a.ag_id=#w.ag_id
    left join def on def.pin=#w.pin
    left join #t on #t.sv_ag_id=a.sv_ag_id and #t.ag_id=#w.ag_id and #t.pin=#w.pin  
    left join (select F.dck, count(f.dck) as FrizCnt from Frizer F  where F.Tip=0 group by F.DCK) FF on FF.dck=#w.dck
  group by a.sv_ag_id, #w.ag_id, #w.pin, def.gpName,
    #w.cnt1,#w.cnt2,#w.cnt3,#w.cnt4,#w.cnt5,#w.cnt6,#w.cnt7, FF.FrizCnt
) E  )
  print 'Из них попали в отчет: '+cast(@UsedPicCount as varchar)

  
end
*/