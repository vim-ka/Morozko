CREATE procedure Guard.CalcOverDet @nd datetime, @Deep int=30, @PrevSunday datetime
as
declare @pn as datetime
begin
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  

  -- Список выплат:
  create table #p(datnom int, plata decimal(12,2));
  insert into #p
  select 
      k.sourdatnom, sum(k.plata) from kassa1 k
  where 
      iif(k.Bank_ID=0,k.nd, k.BankDay)<=@ND 
      and k.oper=-2 and k.Act in ('ВЫ','ВО')
  group by k.sourdatnom;
  create index p_tmp_idx on #p(datnom);    

  -- Список изменений:
  create table #z (datnom int, delta decimal(10,2));
  insert into #z select datnom, sum(izmen) from NcIzmen where nd<=@ND group by datnom;
  create index z_tmp_idx on #z(datnom);    

  -- Скорректированный список накладных, с учетом выплат и изменений, с указанием просрочки:
  create table #N(b_id int, dck int, datnom int, OverDue decimal(12,2), Deep int, nd datetime, srok int);

  insert into #N
  select
    NC.b_id, nc.dck, NC.datnom, 
    nc.sp-isnull(#p.plata,0)+isnull(#z.Delta,0) as OverDue,
    cast( @ND - (nc.nd+nc.srok) as int) as Deep, nc.nd, nc.srok
  from nc
    left join #p on #p.datnom=nc.datnom
    left join #z on #z.datnom=nc.datnom
  where
    nc.nd<=@nd and nc.b_id>0 --and nc.sp>0
    and nc.tara=0 and nc.frizer=0 and nc.actn=0 
    and nc.nd+nc.srok< @ND
    and nc.sp-isnull(#p.plata,0)+isnull(#z.Delta,0) > 1.00

  -- Промежуточный результат, свернутый по договорам:
  create table #pr (dck int, ag_id int, Overdue decimal(12,2), Deep int, LastSundayOver decimal(12,2) default 0);

  insert into #pr(dck,ag_id,overdue,deep)
  select 
    #N.dck, iif(dc.ag_id in (33,641) and dc.prevag_id is not null, dc.PrevAg_ID, dc.ag_id) as AG_ID,
    sum(#N.overdue), max(#N.deep)
  from 
    #N
    inner join defcontract dc on dc.dck=#N.dck
  group BY
    #N.dck, iif(dc.ag_id in (33,641) and dc.prevag_id is not null, dc.PrevAg_ID, dc.ag_id)



      

  -- *******************************************************************************************
  -- *  Возможно, требуется еще посчитать просрочку на вечер предыдущего воскресенья:          *
  -- *******************************************************************************************-
      if @PrevSunDay is not null BEGIN
        -- Список выплат:
        truncate table #p;
        drop index p_tmp_idx on #p;
        insert into #p
        select 
            k.sourdatnom, sum(k.plata) from kassa1 k
        where 
            iif(k.Bank_ID=0,k.nd, k.BankDay)<=@PrevSunday 
            and k.oper=-2 and k.Act in ('ВЫ','ВО')
        group by k.sourdatnom;
        create index p_tmp_idx on #p(datnom);    
        print('   — Список выплат 2 создан')
      
        -- Список изменений:
        truncate table #z;
        drop index z_tmp_idx on #z;
        insert into #z select datnom, sum(izmen) from NcIzmen where nd<=@PrevSunday group by datnom;
        create index z_tmp_idx on #z(datnom);    
        print('   — Список изменений 2 создан')

        -- Скорректированный список накладных, с учетом выплат и изменений, с указанием просрочки:
        truncate table #N
        insert into #N
        select
          NC.b_id, nc.dck, NC.datnom, 
          nc.sp-isnull(#p.plata,0)+isnull(#z.Delta,0) as OverDue,
          cast( @PrevSunday - (nc.nd+nc.srok) as int) as Deep, nc.nd, nc.srok
        from nc
          left join #p on #p.datnom=nc.datnom
          left join #z on #z.datnom=nc.datnom
        where
          nc.nd<=@PrevSunday and nc.b_id>0 --and nc.sp>0
          and nc.tara=0 and nc.frizer=0 and nc.actn=0 
          and nc.nd+nc.srok< @PrevSunday
          and nc.sp-isnull(#p.plata,0)+isnull(#z.Delta,0) > 1.00

        -- Промежуточный результат, свернутый по договорам:
        create table #pr2 (dck int, ag_id int, Overdue decimal(12,2), Deep int);
      
        insert into #pr2(dck,ag_id,overdue,deep)
        select 
          #N.dck, iif(dc.ag_id in (33,641) and dc.prevag_id is not null, dc.PrevAg_ID, dc.ag_id) as AG_ID,
          sum(#N.overdue), max(#N.deep)
        from 
          #N
          inner join defcontract dc on dc.dck=#N.dck
        group BY
          #N.dck, iif(dc.ag_id in (33,641) and dc.prevag_id is not null, dc.PrevAg_ID, dc.ag_id)
        
        print('   — Промежуточная таблица #pr2 создана');
    
        update #pr set #pr.LastSundayOver=#pr2.overdue
        from #PR inner join #pr2 on #pr2.dck=#pr.dck
        print('   — Промежуточная таблица #pr скорректирована');
      end;


  -- Таблица результатов:
  create table #R (depid int, dck int, b_id int, gpname varchar(100), 
    sv_ag_id int, svFam varchar(50), 
    TekOver decimal(12,2), Deep int, LastWeekOver decimal(12,2), MasterDCK int default 0, MasterPin int default 0);

  insert into #R(depid, dck, b_id, gpname, sv_ag_id, svFam, 
    TekOver, Deep, LastWeekOver)
  select -- будет использован виртуальный отдел 300 - Судебный
    iif(#pr.ag_id=32,300, a.depid) as DepID, #pr.dck, dc.pin, left(def.gpname,100), a.sv_ag_id, left(P.Fio,50) as SvFam,
    #pr.Overdue, #pr.Deep,#pr.LastSundayOver
  from 
    #pr 
    inner join defcontract dc on dc.dck=#pr.dck
    inner join def on def.pin=dc.pin
    inner join agentlist A on A.ag_id=#pr.ag_id
    inner join agentlist S on S.ag_id=a.sv_ag_id
    inner join Person P on P.p_id=S.p_id
  where #pr.overdue>0
  order by def.gpname;


  -- Когда был предыдущий понедельник?
  set @pn=(select dateadd(day, 1-datepart(WEEKDAY, dbo.today()), dbo.today()));
  print('Предыдущий понедельник был '+cast(@pn as varchar));

  create table #WeekPay(depid int, dck int, b_id int, sv_id int, plata decimal(12,2));
  insert into #WeekPay(depid, dck, b_id, sv_id, plata)
  SELECT
    a.depid, k.dck, k.B_ID, a.sv_ag_id, sum(k.Plata)
  from 
    Kassa1 K
    inner join defcontract dc on dc.dck=k.DCK
    inner join agentlist A on a.ag_id=iif(dc.ag_id in (33,641) and dc.prevag_id is not null, dc.PrevAg_ID, dc.ag_id)
  where 
    k.nd between @pn and dbo.today()
    and k.oper=-2
    -- and dc.ag_id<>17
  group by a.depid, k.dck, k.B_ID, a.sv_ag_id
  print('   — Таблица выплат за последнюю неделю создана');

  create index wp_temp_idx on #WeekPay(depid,dck,b_id,sv_id);
 
  create table #deps(depid int, dname varchar(70));
  insert into #deps select depid,dname from Deps;
  insert into #deps values(300,'Судебный');


  update #R set MasterPin=def.Master from #R inner join Def on Def.pin=#r.b_id;
  update #R set MasterDCK=(select max(DCK) from defcontract where pin=#r.masterpin and ContrMain=1) where MasterPin>0;
  update #R set MasterPin=B_ID,MasterDCK=DCK where isnull(MasterPIN,0)=0 or isnull(MasterDCK,0)=0;


  -- Список холодильников, свернутый по мастерам сети:
  create table #fr (pin int, FrizQty int);
  insert into #fr 
  select iif(def.Master=0,def.pin,def.master), count(f.nom)
  from frizer f inner join def on def.pin=f.B_ID
  where f.tip=0 
  group by iif(def.Master=0,def.pin,def.master);


  -- Промежуточный результат:
  create table #pz (DepId int, DName varchar(70), sv_ag_id int, svFam varchar(100),
    b_id int, dck int, gpname varchar(255), TekOver decimal(10,2), Deep int, LastWeekOver decimal(10,2), 
    remark varchar(40), Plata decimal(10,2), Mess varchar(50), IncomePlan decimal(10,2), FrizQty int
    );



--  так было:
--  insert into #pz
--  select 
--    e.depid, #deps.dname, e.sv_ag_id, sv.fio as svfam, e.b_id, e.dck, def.gpname, 
--    e.TekOver, e.Deep, e.LastWeekOver, def.remark, E.Plata, DE.Mess, De.IncomePlan, #fr.FrizQty
--  from (
--        select max(#r.depid) depid, max(#r.sv_ag_id) sv_ag_id,  #r.MasterPin as b_id, #r.MasterDCK as dck, 
--          sum(#r.TekOver) TekOver,
--          max(#r.Deep) Deep, sum(#r.LastWeekOver) LastWeekOver, sum(W.Plata) Plata
--        from 
--          #R
--          left join #Weekpay W on w.depid=#r.depid and W.b_id=#r.b_id and W.sv_id=#r.sv_ag_id
--        where (#r.sv_ag_id<>17 or #r.depid=300) and #r.deep>=@Deep
--        group by #r.MasterPin, #r.MasterDCK
--  )  E
--  inner join #Deps on #Deps.DepID=e.depid
--  inner join def on def.pin=e.b_id
--  inner join Agentlist A on A.ag_id=e.sv_ag_id
--  inner join Person SV on SV.p_id=a.p_id
--  left join DefRemark DE on DE.pin=E.b_id
--  left join #fr on #fr.pin=E.b_id;

  -- Новый вариант с 09.02.2018:
  insert into #pz
  select 
    e.depid, #deps.dname, e.sv_ag_id, sv.fio as svfam, e.b_id, e.dck, def.gpname, 
    e.TekOver, e.Deep, e.LastWeekOver, def.remark, E.Plata, DE.Mess, De.IncomePlan, #fr.FrizQty
  from (
        select #r.depid, #r.sv_ag_id, #r.b_id, #r.DCK, 
          sum(#r.TekOver) TekOver,
          max(#r.Deep) Deep, sum(#r.LastWeekOver) LastWeekOver, sum(W.Plata) Plata
        from 
          #R
          left join #Weekpay W on w.depid=#r.depid and W.b_id=#r.b_id and W.sv_id=#r.sv_ag_id
        where (#r.sv_ag_id<>17 or #r.depid=300) and #r.deep>=@Deep
        group by #r.depid, #r.sv_ag_id, #r.b_id, #r.DCK, #r.MasterPin, #r.MasterDCK
  )  E
  inner join #Deps on #Deps.DepID=e.depid
  inner join def on def.pin=e.b_id
  inner join Agentlist A on A.ag_id=e.sv_ag_id
  inner join Person SV on SV.p_id=a.p_id
  left join DefRemark DE on DE.pin=E.b_id
  left join #fr on #fr.pin=E.b_id;

  -- Список последних выплат:
  if object_id('tempdb..#v') is not null drop table #PL;
  create table #PL(b_id int, LastDay datetime, LastPay money);
  insert into #pl(b_id, lastday) 
    select k.b_id, max(k.ND) 
    from 
      Kassa1 k 
      inner join (select distinct b_id from #pz) E on E.b_id=k.b_id
    where 
      k.Oper=-2 
      -- and k.nd>=dbo.today()-365.25*10
      and k.Remark not like '%компенсация%' 
      and k.Remark not like '%возврат%'
      and k.Plata>0
    group by k.B_ID;
  create index pl_temp_idx on #pl(b_id);

  update #PL set LastPay = (select sum(plata) from Kassa1 k where Oper=-2 
      and b_id=#pl.b_id and nd=#pl.LastDay and Remark not like '%компенсация%' 
      and Remark not like '%возврат%'
      and k.Plata>0);
  alter table #pz add LastDay varchar(12);
  alter table #pz add LastPay decimal(10,2);

  update #pz set LastDay=convert(date,#pl.LastDay,104), LastPay=#pl.LastPay
  from #pz inner join #pl on #pl.b_id=#pz.b_id;
  -- update #pz set LastDay='свыше 10 лет' where LastDay is null;

  select * from #pz order by depid, Deep desc, svfam, gpname;


  truncate table Guard.OverDet;
  
  INSERT INTO Guard.OverDet(DepId,DName,sv_ag_id,svFam,b_id,dck,gpname,TekOver,Deep,LastWeekOver,remark,Plata,Mess,IncomePlan,FrizQty,LastDay,LastPay) 
    select DepId,DName,sv_ag_id,svFam,b_id,dck,gpname,TekOver,Deep,LastWeekOver,remark,Plata,Mess,IncomePlan,FrizQty,LastDay,LastPay
    from #pz;
  
  select DepId,DName,sv_ag_id,svFam,b_id,dck,gpname,TekOver,Deep,LastWeekOver,remark,Plata,Mess,IncomePlan,FrizQty
  from Guard.OverDet 
  order by depid, Deep desc, svfam, gpname;

end;