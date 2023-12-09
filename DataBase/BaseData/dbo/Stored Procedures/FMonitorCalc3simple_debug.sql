CREATE procedure dbo.FMonitorCalc3simple_debug @day0 datetime, @day1 datetime
as
begin

  -- Раcпределяем снимки по отделам, супервайзерам, агентам, покупателям, договорам и примечаниям:
  create table #t(DepID int, sv_ag_id int, AG_ID int, Pin int, Dck int, 
    P1 int,P2 int, P3 int, P4 int, P5 int, P6 int, P7 int, p8 int, p9 int, p10 int, p11 int, p12 int, p13 int, p14 int, p15 int, p16 int);

  insert into #t(DepID, sv_ag_id, AG_ID, Pin, Dck, P1, P2, P3, P4, P5, P6, P7, p8,p9,p10,p11,p12,p13,p14,p15,p16)
    select 
      S.DepID, A.sv_ag_id, DC.AG_ID, DC.Pin, F.DCK,
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
      inner join AgentList A on A.ag_id=DC.AG_ID
      inner join AgentList S on S.ag_ID=A.sv_ag_id
    where 
      F.nd between @day0 and @day1
and dc.pin in (26402,33557,38272)
    group by 
      S.DepID, A.sv_ag_id, DC.AG_ID, DC.Pin, F.DCK;
select * from #t;


  -- А это уже результат:
  select sv_id,ag_id,pin,gpname, 0 cnt1, 0 cnt2, 0 cnt3, 0 cnt4, 0 cnt5, 0 cnt6, 0 cnt7, FrizCNT,
    p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16
    from (
    select  a.sv_ag_id as sv_id, #t.ag_id, #t.pin, def.gpName,
      -- #w.cnt1,#w.cnt2,#w.cnt3,#w.cnt4,#w.cnt5,#w.cnt6,#w.cnt7, 
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
      #t
      left join agentlist a on a.ag_id=#t.ag_id
      left join def on def.pin=#t.pin
      left join (select F.dck, count(f.dck) as FrizCnt from Frizer F  where F.Tip=0 group by F.DCK) FF on FF.dck=#t.dck
    )E 
    where 
      -- cnt1+cnt2+cnt3+cnt4+cnt5+cnt6+cnt7<>0 or 
      p1+p2+p3+p4+p5+p6+p7+p8+p9+p10+p11+p12+p13+p14+p15+p16<>0
      or FrizCNT<>0
    order by sv_id,ag_id,pin  

end;