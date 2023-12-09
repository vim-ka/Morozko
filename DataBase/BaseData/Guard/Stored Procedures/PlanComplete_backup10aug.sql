CREATE procedure [Guard].[PlanComplete_backup10aug] @ag_id int, @Mode tinyint, @NeedDay datetime, @Comp varchar(30)=null
-- @Mode=1 - для агента, @Mode=2 - супервайзера, @Mode=3 - тыщик 
as
declare @sunday datetime, @SellDate date, @PrevDate date,
  @dn tinyint, @dofw tinyint, @d tinyint, @Tekpin int, @Pin int, @PrevPin int,
  @dck int, @tekdck int, @ss varchar(21),
  @today datetime, @yesterday datetime
-- На выходе процедуры будут еще четыре поля: продажи с предыдущего воскресенья,
-- т.е. это всегда за последние 1..7 дней, и также продажи за месяц,
-- подразумевая продажи за период @NeedDay-29...@NeedDay включительно (за 30 дней),
-- и еще количество холодильников на точке на момент прямо сейчас, 
-- и количество сделанных фотографий за требуемый день.

begin
  set transaction isolation level read uncommitted
  set @dn = datepart(weekday, @NeedDay); -- день недели,1=понедельник
  set @today=dbo.today()
  set @yesterday=dateadd(day,-1,@today);
  
  -- Список агентов:
  create table #Ag(ag_id int);
  
  -- это или один агент, или все агенты одного супервайзера:
  if @mode=1 insert into #ag values(@ag_id);
  else if @mode=2 insert into #ag(ag_id) select ag_id from agentlist a where a.sv_ag_id=@ag_id;
  
  -- Теперь список покупателей с их договорами:
  create table #Br(dck int, b_id int, Plann bit, ag_id int,  dt char(5), Tip smallint default 0,
    BName varchar(100), factT char(8), SkipT char(8), Tara int,
    Audit char(8), AdvOrd char(8), NeudSpr int, LastSver date, LastSell date, DayProd char(20), 
    Debt decimal(12,2) default 0, Overdue decimal(12,2) default 0, Over17 decimal(12,2) default 0, Deep int );
  -- и таблица долгов и просрочек:
  create table #OV(dck int, debt decimal(10,2), Overdue decimal(10,2), Over17 decimal(10,2), Deep int, LastSell datetime );  


    
  -- ***************************************************************************************************
  -- **   Долг и просрочка для Тыщика, должники больше 17 дней по состоянию на вечер вчерашнего дня   **
  -- ***************************************************************************************************
  if @mode=3 begin
    -- Долг и просрочка для Тыщика, должники больше 17 дней по состоянию на вечер вчерашнего дня:
    
    
    insert into #OV
      select 
        s.dck, s.debt, 
        S.Overdue-isnull(E.Plata,0) as Overdue, 
        s.OverUp17-isnull(E.Plata,0) as Over17, 
        s.Deep, L.LastSell
      from 
        DailySaldoDck S 
        inner join defcontract dc on dc.dck=s.dck
        left join (select DCK,sum(plata) as Plata from Kassa1 where nd=@today and oper=-2 group by dck) E on e.dck=s.dck
        left join (select nc.dck, max(nc.nd) as LastSell 
          from nc where actn=0 and frizer=0 and tara=0 
          and nc.nd>=DATEADD(year,-2,@today) group by nc.dck) L on L.dck=S.dck
      where s.Nd=@yesterday and s.OverUp17-isnull(E.Plata,0)>=0.50

    insert into #br(dck,b_id,debt,overdue,over17,Deep,LastSell) 
    select #ov.dck, dc.pin,#ov.debt,#ov.overdue,#ov.over17,#OV.Deep,#ov.Lastsell
    from #ov inner join defcontract dc on dc.dck=#ov.dck;

  end;    

  -- ***************************************************************************************************
  -- **   Все покупатели, относящиеся к заданному списку агентов, в соответствии с планом посещений   **
  -- ***************************************************************************************************
  else begin
    insert into #br(dck,b_id,Plann,ag_id)
    select distinct 
      p.dck, p.pin, 1 as Plann, p.ag_id
    from
      planvisit2 P 
      inner join #ag on #ag.ag_id =p.ag_id    
    where
      p.dn=@dn and p.dck>0
    

    -- Еще туда же воткнем всех покупателей, по которым были оплаты от агентов за день, даже неплановые:  
    insert into #br(dck,b_id,Plann,ag_id)
    select k.dck, k.b_id, 0 as Plann,k.op-1000
    from 
      kassa1 k 
      inner join #ag on k.op-1000=#ag.ag_id
    where k.nd=@NeedDay 
      and k.dck not in (select dck from #br)
      and k.dck>0
    -- а также покупателей, которым агент что-то продал:
    UNION
    select nc.dck, nc.b_id, 0 as Plann,nc.ag_id
    from 
      nc
      inner join #ag on #ag.ag_id=nc.ag_id
    where nc.nd=@NeedDay
      and nc.dck not in (select dck from #br)
      and nc.dck>0
    -- а также покупателей, холодильники которых агент сфотографировал за этот день:
    UNION
    select distinct FM.dck, def.pin, 0 as Plann,dc.ag_id
    from 
      Guard.FMonitor FM 
      inner join DefContract DC on DC.dck=fm.dck
      inner join Def on Def.pin=DC.pin
      inner join #ag on #ag.ag_id=dc.ag_id
    where 
      FM.nd=@needday
      and fm.dck not in (select dck from #br)
      and fm.dck>0



    -- Долг и просрочка:
    -- Должники по состоянию на вечер вчерашнего дня:
    insert into #OV
      select 
        s.dck, s.debt, 
        S.Overdue-isnull(E.Plata,0) as Overdue, 
        s.OverUp17-isnull(E.Plata,0) as Overdue17, 
        s.Deep, L.LastSell
      from 
        DailySaldoDck S 
        left join (select DCK,sum(plata) as Plata from Kassa1 where nd=@today and oper=-2 group by dck) E on e.dck=s.dck
        left join (select nc.dck, max(nc.nd) as LastSell 
          from nc where actn=0 and frizer=0 and tara=0 
          and nc.nd>=DATEADD(year,-2,@today) group by nc.dck) L on L.dck=S.dck
      where s.Nd=@yesterday
        and s.dck in (select dck from #br);
  end;

  -- Какие же долги и просрочки у покупателей?
  update #br 
    set LastSell=#OV.LastSell, debt=#ov.debt, overdue=#ov.overdue, 
      over17=#ov.over17, Deep=#ov.deep
    from #br inner join #ov on #ov.dck=#br.dck;

  -- Пропишем еще кое-какие реквизиты:
  update #br
    set #br.ag_id=dc.ag_id    
    from #br inner join defcontract dc on dc.dck=#br.dck
  --  where isnull(#br.ag_id,0)=0
    
  update #br
    set #br.bname=def.brName, #br.LastSver=Def.LastSver
    from #br inner join Def on Def.pin=#br.b_id;
  
  update #br set tara=(select sum(tr.kol) from TaraDet tr where tr.b_id=#br.b_id);
  
  update #br 
    set #br.Audit=E.Audit
    from #Br
    inner join (select dck,convert(char(8),MIN(r.nd),108) as Audit from Rests r 
      where r.nd>=@NeedDay and r.nd<dateadd(day,1,@NeedDay) group by dck
    ) E on E.dck=#br.dck;
    
  update #Br 
  set dt=guard.MinuteToTime(p.tm), tip=p.tip 
  from 
    #br 
    inner join planvisit2 p on p.dck=#br.dck
    inner join #ag on #ag.ag_id=p.ag_id
  where p.dn=@dn
  

  --**********************************************************************************
  -- **   ТАБЛИЦА ПОСЕЩЕНИЙ, УЧИТЫВАЕМЫХ В ОТЧЕТЕ И ПРОПУСКАЕМЫХ ТОЖЕ               **
  --**********************************************************************************
  
  create table #po (dck int, tm varchar(8) default '', TmSkip varchar(8) default '');
  insert into #po(dck,tm)
  select e.dck, MIN(tm) tm from (
    select nc.dck, convert(char(8),nc.tm,108) as tm
    from 
      NC
      inner join defcontract dc on dc.dck=nc.DCK
    where
      nc.ND=@NeedDay
      and nc.sp>0
      and nc.remarkop not like 'w.%'
      and nc.op>1000
    UNION
    select nc.dck, convert(char(8),k.tm,108) as tm
    from 
      kassa1 k
      inner join nc on nc.DatNom=k.sourdatnom
    where
      k.oper=-2 and k.nd=@NeedDay and k.remark not like 'Компенсация%' and k.remark not like 'Вычерк%'
      and nc.sp>0
  ) E group by e.dck; 
  
  insert into #po(dck,tmSkip)
  select e.dck, MIN(tm) tm from (
    select nc.dck, convert(char(8),nc.tm,108) as tm
    from 
      NC
      inner join defcontract dc on dc.dck=nc.DCK
    where
      nc.ND=@NeedDay
      and nc.sp>0
      and (nc.remarkop like 'w.%'  or nc.op<1000)
  ) E group by e.dck; 
  
  
  
  update #Br set FactT=#Po.tm from #BR inner join #po on #po.dck=#br.dck and #po.tm<>'';
  update #Br set SkipT=#Po.tmSkip from #BR inner join #po on #po.dck=#br.dck and #po.tmSkip<>'';
  
  create table #ao(pin int,tm varchar(8));
  insert into #ao select pin, convert(char(8),MIN(a.nd),108) 
    from AdvOrder a where a.nd>@NeedDay and a.nd<dateadd(day,1,@NeedDay)
    group by Pin;
  update #BR set #BR.AdvOrd=#ao.tm from #BR inner join #ao on #ao.pin=#br.b_id;
  
  -- Какой сегодня день недели? И какая дата была последнего воскресенья?
  set @dofw=datepart(weekday, @NeedDay);
  if @dofw=7 set @dofw=0;
  set @sunday=dateadd(day, -@dofw,  @NeedDay);

  -- Создаю временную таблицу - список продаж покупателям с воскресенья, разбитый по дням недели
  create table #P(dck int, SellDate datetime);
  -- Втыкаю в нее только интересующих нас покупателей:
  insert into #P 
    select distinct nc.dck, nc.nd
    from #br inner join nc on nc.dck=#br.dck
    where nc.nd>=@sunday and nc.nd<=@needDay and nc.tara=0 and nc.actn=0 and nc.frizer=0 and nc.sp>0;
  declare c1 cursor fast_forward for select * from #p order by dck, SellDate;
  open c1;
  fetch next from c1 into @dck,@SellDate;
  while (@@FETCH_STATUS=0) begin
    set @ss=''
    set @TekDCK=@DCK
    while (@@FETCH_STATUS=0) and (@TekDCK=@DCK) begin
      set @ss=@ss+SUBSTRING('пн,вт,ср,чт,пт,сб,вс,', 3*datepart(weekday,@Selldate)-2, 3);
      fetch next from c1 into @dck,@SellDate;
    end;
    update #br set DayProd=SUBSTRING(@ss,1,LEN(@ss)-1) where #br.dck=@Tekdck;
  end;
  close c1;
  deallocate c1;  
  
  -- кусочек кассовых операций:
  create table #k(nd datetime,dck int, plata decimal(12,2));
  insert into #k
    select k.nd, k.dck,sum(k.plata) as plata
    from 
      kassa1 k
    where k.oper=-2 and k.Act in ('ВЫ','ВО') 
    and k.nd>=dateadd(day, -29, @NeedDay) and k.nd<=@NeedDay
    and K.DCK IN (select dck from #br)
    group by k.nd, k.dck;
  create index k_tmp_idx on #k(nd,dck);
  
  
  -- Список продаж за сегодня:
  create table #dp(dck int,TodaySell decimal(12,2));
  insert into #dp  select dck, sum(sp) as TodaySell 
    from nc where nd=dbo.today() group by dck;
  create index dp_bid_idx on #dp(dck);

  -- Список продаж за неделю, точнее, с последнего предыдущего воскресенья по @NeedDay:
  create table #wp(dck int,WeekSell decimal(12,2));
  insert into #wp  select dck, sum(sp) as WeekSell 
    from nc where nd>=@sunday and nd<=@needday group by dck;
  create index wp_bid_idx on #wp(dck);
  
  -- Список продаж за месяц, точнее, за последние 30 дней перед @NeedDay, включая @NeeDay:
  create table #mp(dck int,MonthSell decimal(12,2));
  insert into #mp  select dck,sum(sp) as MonthSell from nc where nd>=dateadd(day, -29, @NeedDay) and nd<=@needday group by dck;
  create index mp_bid_idx on #mp(dck);
  
  -- Список оплат за неделю, аналогично:
  create table #wm(dck int,WeekPay decimal(12,2));
  insert into #wm  select dck,sum(plata) as WeekPay from #k where nd between @sunday and @needday group by dck;
  create index wm_bid_idx on #wm(dck);

  -- Список оплат за месяц, аналогично:
  create table #mm(dck int,MonthPay decimal(12,2));
  declare @MonOne datetime;
  set @MonOne=dateadd(day, -29, @NeedDay);
  insert into #mm  select dck,isnull(sum(plata),0) as MonthPay 
    from #k where nd between @MonOne and @needday 
    group by dck;
  create index mm_bid_idx on #mm(dck);
  
  -- Последние тревожные сообщения насчет сверок по договорам:
  create table #m(dck int, daid int)  ;
  insert into #m select dck, MAX(daid) daid from DefAlert group by dck;
  create index m_temp_idx on #m(dck);
  create table #AL(dck int, LastSverSVDate datetime, LastSverSVState int);
  insert into #AL
    select #m.dck, da.ND, da.Tip
    from #m inner join defalert DA on DA.daid=#m.daid
  
  -- Холодильники:
  create table #f(dck int, qty int);
  insert into #f select dck,count(dck) from frizer where tip=0 and dck in (select dck from #br) group by dck;
  
  -- Фотографии:
  create table #PH (dck int, Photos smallint);
  insert into #PH select fm.dck, count(fp.fmid)
  from Guard.FMonitor fm
    inner join Guard.FMonitorPics fp on fp.fmid=fm.fmID
    where fm.nd=@NeedDay and fm.dck in (select dck from #br) group by fm.dck;
 
  -- select * from #br order by dck;

  if @Comp is not null delete from guard.PlanExec where Comp=@Comp;
  if @Comp is null
    select @Comp as Comp, #br.dck, #br.b_id,#br.plann, #br.ag_id,#br.dt,#br.BName, #br.factT, #br.Tara, 
      #br.Audit, #br.AdvOrd,  #br.NeudSpr, #br.LastSver, #br.LastSell, 
      #br.DayProd, #br.Debt, 
      iif(#br.Overdue<0,0,#br.Overdue) Overdue,  
      iif(#br.Over17<0,0,#br.Over17) Over17,  
      #br.Deep, 
      #wp.WeekSell, #mp.MonthSell,
      #wm.WeekPay, #mm.MonthPay, A.DepID, A.sv_ag_id,
      P.Fio as SuperFam,
      sum(#k.plata) as DayPay,
      #f.qty as FrizQty,
      def.gpAddr, #AL.LastSverSVDate, #AL.LastSverSVState, #PH.Photos
    from 
      #br 
      left join #k on #k.dck=#br.dck and #k.nd=@NeedDay
      left join #wp on #wp.dck=#br.dck
      left join #mp on #mp.dck=#br.dck
      left join #wm on #wm.dck=#br.dck
      left join #mm on #mm.dck=#br.dck
      left join Agentlist A on A.ag_id=#br.ag_id
      left join Agentlist S on S.ag_id=A.sv_ag_id
      left join Person P on P.P_ID=S.P_ID
      left join #F on #F.dck=#br.dck
      left join Def on Def.pin=#br.b_id
      left join #AL on #AL.dck=#br.dck
      left join #PH on #PH.dck=#br.dck
    where 
      (#br.overdue>0 and #br.deep>=17) or @Mode<3
    group by #br.dck,#br.b_id,#br.plann, #br.ag_id,#br.dt,#br.BName, #br.factT, #br.Tara, 
      #br.Audit, #br.AdvOrd,  #br.NeudSpr, #br.LastSver, #br.LastSell, 
      #br.DayProd, #br.Debt, #br.Overdue, #br.Over17, #br.Deep,  
      #wp.WeekSell, #mp.MonthSell, #wm.WeekPay, #mm.MonthPay,A.DepID, A.sv_ag_id,P.Fio,
      #f.qty, def.gpAddr, #al.LastSverSVDate, #al.LastSverSVState, #PH.Photos
    order by A.sv_ag_id, ag_id, #br.bname, b_id;
  else BEGIN
 
    INSERT INTO Guard.PlanExec
    ( Comp,  dck,  b_id,  Plann,  ag_id,  dt, Tip, BName,  FactT, SkipT,  Tara,  Audit,
      AdvOrd,  NeudSpr,  LastSver,  LastSell,  DayProd,  Debt,  Overdue,
      Over17,  Deep,  WeekSell,  MonthSell,
      WeekPay, MonthPay, 
      DepID,  sv_ag_id,  SuperFam,
      DayPay,  FrizQty,  gpAddr,  LastSverSVDate,  LastSverSVState, Photos, AgentFam, TodaySell, 
      PlanLikvid, FactLikvid, PlanLikvidPcs, FactLikvidPcs, FactBrak, FactBrakPcs) 
    select @Comp, #br.dck, #br.b_id,#br.plann, #br.ag_id, #br.dt, #br.tip, #br.BName, 
      #br.factT, #br.SkipT, #br.Tara, #br.Audit, 
      #br.AdvOrd,  #br.NeudSpr, #br.LastSver, #br.LastSell,  #br.DayProd, #br.Debt,      
      iif(#br.Overdue<0,0,#br.Overdue) Overdue,  
      iif(#br.Over17<0,0,#br.Over17) Over17,   #br.Deep,  #wp.WeekSell, #mp.MonthSell,
      #wm.WeekPay, #mm.MonthPay, 
      A.DepID, A.sv_ag_id,   P.Fio as SuperFam,
      sum(#k.plata) as DayPay,  #f.qty as FrizQty, def.gpAddr, #AL.LastSverSVDate, 
      #AL.LastSverSVState, #PH.Photos, PA.Fio, isnull(#dp.todaysell,0), 
      L.sweight, RQ.FactLiqvid, L.PlanLikvidPcs, RQ.FactLikvidPcs, RQ.FactBrak, RQ.FactBrakPcs
    from 
      #br 
      left join #k on #k.dck=#br.dck and #k.nd=@NeedDay
      left join #wp on #wp.dck=#br.dck
      left join #mp on #mp.dck=#br.dck
      left join #dp on #dp.dck=#br.dck
      left join #wm on #wm.dck=#br.dck
      left join #mm on #mm.dck=#br.dck
      left join Agentlist A on A.ag_id=#br.ag_id
      LEFT JOIN Person PA ON PA.P_ID=A.P_ID
      left join Agentlist S on S.ag_id=A.sv_ag_id
      left join Person P on P.P_ID=S.P_ID
      left join #F on #F.dck=#br.dck
      left join Def on Def.pin=#br.b_id
      left join #AL on #AL.dck=#br.dck
      left join #PH on #PH.dck=#br.dck
      left join 
        (select 
            L.ag_id, 
            dc.pin as B_ID, sum(iif(nm.flgWeight=1,weight,0)) as SWeight,
            round(sum(iif(nm.flgWeight=0,weight,0)),0) as PlanLikvidPcs
          from 
            PlanLikvid L 
            inner join Nomen NM on NM.Hitag=L.Hitag
            inner join Defcontract dc on dc.dck=L.dck
          where L.nd=@NeedDay group by L.ag_id,dc.pin
        ) L on L.ag_id=#br.ag_id and L.b_id=#br.b_id
      left join (
        select 
          R.AG_ID, N.Pin as B_ID, 
          sum(iif(R.meta=6,d.fact_weight,0)) FactLiqvid,
          sum(iif(R.meta=6 and d.fact_weight=0,d.kol,0)) as FactLikvidPcs,
          sum(iif(R.meta in (4,5),d.fact_weight,0)) FactBrak,
          sum(iif(R.meta in (4,5) and d.fact_weight=0,d.kol,0)) as FactBrakPcs
        from
          reqreturn N
          inner join requests R on R.Rk=N.reqnum
          inner join ReqReturnDet D on D.reqretid=N.reqnum
          inner join Nomen nm on nm.hitag=d.hitag
        where
          R.ND>=@NeedDay and R.ND<@NeedDay+1
        group by R.AG_ID, N.Pin      
        ) RQ on RQ.ag_id=#br.ag_id and RQ.b_id=#br.b_id
    where 
      (#br.overdue>0 and #br.deep>=17) or @Mode<3
    group by #br.dck,#br.b_id,#br.plann, #br.ag_id,#br.dt, #br.tip, #br.BName, #br.factT, #br.SkipT, #br.Tara, 
      #br.Audit, #br.AdvOrd,  #br.NeudSpr, #br.LastSver, #br.LastSell, 
      #br.DayProd, #br.Debt, #br.Overdue, #br.Over17, #br.Deep,  
      #wp.WeekSell, #mp.MonthSell, #wm.WeekPay, #mm.MonthPay,A.DepID, A.sv_ag_id,P.Fio,
      #f.qty, def.gpAddr, #al.LastSverSVDate, #al.LastSverSVState, #PH.Photos, PA.Fio,#dp.todaysell, L.sweight, 
      RQ.FactLiqvid, RQ.FactLikvidPcs,  RQ.FactBrak,  RQ.FactBrakPcs,
      L.PlanLikvidPCS
    order by A.sv_ag_id, ag_id, #br.bname, b_id;
    select top 1 * from guard.planexec where Comp=@Comp order by b_id;
  end;

end;