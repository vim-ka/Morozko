-- Расчет продаж только по группе колбасы (92-Микоян или 126-Царицыно)
CREATE procedure Guard.PlanGroupComplete @Who int, @Mode tinyint, @ND datetime, @Ngrp smallint=92
-- @Mode=1 - для агента, @Mode=2 - супервайзера
as
declare @Comp varchar(30),
  @sunday datetime, @SellDate date, @PrevDate date,
  @dn smallint, @dofw tinyint, @d tinyint, @Tekpin int, @Pin int, @PrevPin int,
  @dck int, @tekdck int, @ss varchar(21),
  @today datetime, @yesterday datetime

begin
  set transaction isolation level read uncommitted
  set @dn = datepart(weekday, @ND); -- день недели,1=понедельник
  set @today=dbo.today()
  set @yesterday=@today-1;
  set @Comp=HOST_NAME();
  
  -- Список агентов, это или один агент, или все агенты одного супервайзера:
  create table #Ag(ag_id int);
  if @mode=1 insert into #ag(ag_id) values(@Who)
  else if @mode=2 insert into #ag(ag_id) select ag_id from agentlist a where a.sv_ag_id=@Who;

  -- Теперь список покупателей:
  create table #Br(ag_id int, b_id int, Plann bit, dt char(5), FactT varchar(8), 
    Tip smallint default 0,  BName varchar(100), 
    SaleKolbRub decimal(10,2), SaleKolbKG decimal(10,3));

  -- ***************************************************************************************************
  -- **   Все покупатели, относящиеся к заданному списку агентов, в соответствии с планом посещений   **
  -- ***************************************************************************************************
  insert into #br(b_id,Plann,ag_id)
  select distinct 
    p.pin, 1 as Plann, p.ag_id
  from
    planvisit2 P 
    inner join #ag on #ag.ag_id =p.ag_id    
  where
    p.dn=@dn and p.dck>0

  -- а также все покупатели, которым агент что-то продал:
  insert into #BR(b_id,Plann,ag_id)
  select distinct nc.b_id, 0 as Plann, nc.op-1000 as AG_ID
  from 
    nc
    inner join #ag on #ag.ag_id=nc.op-1000
  where 
    nc.nd=@ND and nc.op>1000
    and not exists(select * from #br where b_id=nc.b_id and ag_id=nc.op-1000)

  update #Br 
  set dt=guard.MinuteToTime(p.tm), tip=p.tip
  from 
    #br 
    inner join planvisit2 p on p.ag_id=#br.ag_id and p.pin=#br.b_id
    inner join #ag on #ag.ag_id=p.ag_id
  where p.dn=@dn

  update #Br set BName=Def.gpname from #BR inner join Def on Def.Pin=#BR.b_id;

  if @ND=dbo.today() begin
     -- За сегодня учитываем продажи + заявки:
     update #BR set SaleKolbRub=E.SP, SaleKolbKG=E.KG, FactT=e.TM
     from 
      #Br 
      inner join (
        select nc.b_id, nc.op-1000 as Ag_ID,
        sum(nv.kol*nv.price*(1.0+nc.extra*0.01)) as SP,
        sum(nv.kol*iif(v.weight>0, v.weight, nm.netto)) as KG,
        convert(char(8),min(nc.tm),108) as TM
        from 
          nc
          inner join nv on nv.datnom=nc.DatNom
          inner join tdvi v on v.id=nv.tekid
          inner join Nomen NM on nm.hitag=nv.hitag
        where nc.nd=@ND and nm.Ngrp=@Ngrp
        group by nc.b_id, nc.op-1000
      ) E on E.Ag_ID=#br.ag_id and E.B_ID=#br.b_id;

     update #BR set SaleKolbRub=isnull(SaleKolbRub,0)+E.SP, SaleKolbKG=isnull(SaleKolbKG,0)+E.KG,
       FactT=e.TM
     from 
      #Br 
      inner join (
        select nc.b_id, nc.op-1000 as Ag_ID,
        sum(z.Zakaz*nm.netto*z.cost*1.1) as SP,
        sum(z.Zakaz*nm.netto) as KG,
        convert(char(8),min(nc.tm),108) as tm
        from 
          nc
          inner join nvzakaz z on z.datnom=nc.DatNom
          inner join Nomen NM on nm.hitag=z.hitag
        where nc.nd=@ND and nm.Ngrp=@Ngrp and z.done=0
        group by nc.b_id, nc.op-1000
      ) E on E.Ag_ID=#br.ag_id and E.B_ID=#br.b_id;
  end;
  ELSE -- а за прошлые дни только продажи
     update #BR set SaleKolbRub=E.SP, SaleKolbKG=E.KG, FactT=e.TM
     from 
      #Br 
      inner join (
        select nc.b_id, nc.op-1000 as Ag_ID,
        sum(nv.kol*nv.price*(1.0+nc.extra*0.01)) as SP,
        sum(nv.kol*iif(v.weight>0, v.weight, nm.netto)) as KG,
        convert(char(8),min(nc.tm),108) as tm
        from 
          nc
          inner join nv on nv.datnom=nc.DatNom
          inner join visual v on v.id=nv.tekid
          inner join Nomen NM on nm.hitag=nv.hitag
        where nc.nd=@ND and nm.Ngrp=@Ngrp
        group by nc.b_id, nc.op-1000
      ) E on E.Ag_ID=#br.ag_id and E.B_ID=#br.b_id;
    
  
  -- select * from #br order by ag_id, b_id;
  
  delete from guard.PlanExec where Comp=@Comp;

  INSERT INTO Guard.PlanExec
    ( Comp,  b_id,  Plann,  ag_id,  dt, Tip, BName,  FactT,
      DayProd, TodaySell, gpAddr, AgentFam ) 
  select @Comp, #br.b_id,#br.plann, #br.ag_id, #br.dt, #br.tip, #br.BName,  #br.factT,  
    cast(#br.SaleKolbKG as varchar)+' кг', #br.SaleKolbRub,   def.gpAddr, pa.Fio as AgentFam
  from 
    #br 
    left join Agentlist A on A.ag_id=#br.ag_id
    LEFT JOIN Person PA ON PA.P_ID=A.P_ID
    left join Def on Def.pin=#br.b_id;

select top 1 * from Guard.PlanExec pe where Comp=@Comp order by ag_id, b_id;



/*

-- Новый фрагмент, добавлен 10.08.2017, расчет плана и фактического брака и ликвида:
if object_id('tempdb..#LQ') is not null drop table #LQ;
create table #LQ(B_ID int,Hitag int, Name varchar(100), Weight decimal(10,3) default 0,
  FactBrakPcs int default 0, FactBrak decimal(10,3) default 0,
  LikvidPcs int default 0, Likvid decimal(10,3) default 0, NoData bit default 1 );

insert into #LQ(B_ID, hitag,name,weight, NoData)
select
  E.B_ID, L.Hitag, nm.name, sum(L.Weight) Weight, 1
from
  Guard.PlanLikvid L
  inner join Defcontract DC on DC.DCk=L.Dck
  inner join nomen nm on nm.hitag=l.hitag
  inner join (select distinct B_ID from #BR) E on E.B_ID=DC.Pin
where l.ag_id = @Who and L.ND = @ND
group by E.B_ID, L.Hitag, nm.name;

insert into #LQ(B_ID, Hitag,Name,FactBrakPcs, FactBrak, LikvidPcs, Likvid, NoData)
select
  E.B_ID, d.Hitag, nm.name,
  sum(iif(r.meta in (4,5), d.kol,0)) FactBrakPcs,
  sum(iif(r.meta in (4,5), d.fact_weight,0)) FactBrak,
  sum(iif(r.meta=6, d.kol,0)) LikvidPcs,
  sum(iif(r.meta=6, d.fact_weight,0)) Likvid,
  iif(D.reqretid is null,1,0) as NoData
from
  reqreturn N
  inner join requests R on R.Rk=N.reqnum
  left join ReqReturnDet D on D.reqretid=N.reqnum
  inner join Nomen nm on nm.hitag=d.hitag
  inner join (select distinct b_id from #BR) E on E.b_id=N.pin
where
  R.ND>=@ND and R.ND<@ND+1
  and r.ag_id=@Who
group by E.b_id, d.hitag, nm.name,iif(D.reqretid is null,1,0);



-- SELECT * FROM #LQ;





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
      nc.ND=@ND
      and nc.sp>0
      and nc.remarkop not like 'w.%'
      and nc.op>1000
    UNION
    select nc.dck, convert(char(8),k.tm,108) as tm
    from 
      kassa1 k
      inner join nc on nc.DatNom=k.sourdatnom
    where
      k.oper=-2 and k.nd=@ND and k.remark not like 'Компенсация%' and k.remark not like 'Вычерк%'
      and nc.sp>0
  ) E group by e.dck; 
  
  insert into #po(dck,tmSkip)
  select e.dck, MIN(tm) tm from (
    select nc.dck, convert(char(8),nc.tm,108) as tm
    from 
      NC
      inner join defcontract dc on dc.dck=nc.DCK
    where
      nc.ND=@ND
      and nc.sp>0
      and (nc.remarkop like 'w.%'  or nc.op<1000)
  ) E group by e.dck; 
  
  
  
  update #Br set FactT=#Po.tm from #BR inner join #po on #po.dck=#br.dck and #po.tm<>'';
  update #Br set SkipT=#Po.tmSkip from #BR inner join #po on #po.dck=#br.dck and #po.tmSkip<>'';
  
  create table #ao(pin int,tm varchar(8));
  insert into #ao select pin, convert(char(8),MIN(a.nd),108) 
    from AdvOrder a where a.nd>@ND and a.nd<dateadd(day,1,@ND)
    group by Pin;
  update #BR set #BR.AdvOrd=#ao.tm from #BR inner join #ao on #ao.pin=#br.b_id;
  
  -- Какой сегодня день недели? И какая дата была последнего воскресенья?
  set @dofw=datepart(weekday, @ND);
  if @dofw=7 set @dofw=0;
  set @sunday=dateadd(day, -@dofw,  @ND);

  -- Создаю временную таблицу - список продаж покупателям с воскресенья, разбитый по дням недели
  create table #P(dck int, SellDate datetime);
  -- Втыкаю в нее только интересующих нас покупателей:
  insert into #P 
    select distinct nc.dck, nc.nd
    from #br inner join nc on nc.dck=#br.dck
    where nc.nd>=@sunday and nc.nd<=@ND and nc.tara=0 and nc.actn=0 and nc.frizer=0 and nc.sp>0;
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
    and k.nd>=dateadd(day, -29, @ND) and k.nd<=@ND
    and K.DCK IN (select dck from #br)
    group by k.nd, k.dck;
  create index k_tmp_idx on #k(nd,dck);
  
  
  -- Список продаж за сегодня: Здесь, Виктор!
  create table #dp(dck int,TodaySell decimal(12,2));
  insert into #dp  select dck, sum(sp) as TodaySell 
    from nc where nd=dbo.today() group by dck;
  create index dp_bid_idx on #dp(dck);


  -- Список продаж за неделю, точнее, с последнего предыдущего воскресенья по @ND:
  create table #wp(dck int,WeekSell decimal(12,2));
  insert into #wp  select dck, sum(sp) as WeekSell 
    from nc where nd>=@sunday and nd<=@ND group by dck;
  create index wp_bid_idx on #wp(dck);

  
  -- Список продаж за месяц, точнее, за последние 30 дней перед @ND, включая @NeeDay:
  create table #mp(dck int,MonthSell decimal(12,2));
  insert into #mp  select dck,sum(sp) as MonthSell from nc where nd>=dateadd(day, -29, @ND) and nd<=@ND group by dck;
  create index mp_bid_idx on #mp(dck);
  
  -- Список оплат за неделю, аналогично:
  create table #wm(dck int,WeekPay decimal(12,2));
  insert into #wm  select dck,sum(plata) as WeekPay from #k where nd between @sunday and @ND group by dck;
  create index wm_bid_idx on #wm(dck);

  -- Список оплат за месяц, аналогично:
  create table #mm(dck int,MonthPay decimal(12,2));
  declare @MonOne datetime;
  set @MonOne=dateadd(day, -29, @ND);
  insert into #mm  select dck,isnull(sum(plata),0) as MonthPay 
    from #k where nd between @MonOne and @ND 
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
    where fm.nd=@ND and fm.dck in (select dck from #br) group by fm.dck;
 
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
      left join #k on #k.dck=#br.dck and #k.nd=@ND
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
      L.sweight, L.FactLikvid, L.PlanLikvidPcs, L.FactLikvidPcs, L.FactBrak, L.FactBrakPcs
    from 
      #br 
      left join #k on #k.dck=#br.dck and #k.nd=@ND
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
      left join (
          select #lq.B_ID, 
          sum(iif(nm.flgWeight=1,#lq.weight,0)) as SWeight,
          round(sum(iif(nm.flgWeight=0,#lq.weight,0)),0) as PlanLikvidPcs,
          sum(#LQ.FactBrak) FactBrak,
          sum(#LQ.FactBrakPcs) FactBrakPcs,
          sum(#LQ.Likvid) FactLikvid,
          sum(#LQ.LikvidPcs) FactLikvidPcs
          from 
            #Lq 
            inner join Nomen NM on NM.Hitag=#lq.Hitag
            group by #lq.b_id
        ) L on L.b_id=#br.b_id
-- Так было:
--        (select 
--            L.ag_id, 
--            dc.pin as B_ID, sum(iif(nm.flgWeight=1,weight,0)) as SWeight,
--            round(sum(iif(nm.flgWeight=0,weight,0)),0) as PlanLikvidPcs
--          from 
--            PlanLikvid L 
--            inner join Nomen NM on NM.Hitag=L.Hitag
--            inner join Defcontract dc on dc.dck=L.dck
--          where L.nd=@ND group by L.ag_id,dc.pin
--        ) L on L.ag_id=#br.ag_id and L.b_id=#br.b_id

--      left join (
--        select 
--          R.AG_ID, N.Pin as B_ID, 
--          sum(iif(R.meta=6,d.fact_weight,0)) FactLikvid,
--          sum(iif(R.meta=6 and d.fact_weight=0,d.kol,0)) as FactLikvidPcs,
--          sum(iif(R.meta in (4,5),d.fact_weight,0)) FactBrak,
--          sum(iif(R.meta in (4,5) and d.fact_weight=0,d.kol,0)) as FactBrakPcs
--        from
--          reqreturn N
--          inner join requests R on R.Rk=N.reqnum
--          inner join ReqReturnDet D on D.reqretid=N.reqnum
--          inner join Nomen nm on nm.hitag=d.hitag
--        where
--          R.ND>=@ND and R.ND<@ND+1
--        group by R.AG_ID, N.Pin      
--        ) RQ on RQ.ag_id=#br.ag_id and RQ.b_id=#br.b_id

    where 
      (#br.overdue>0 and #br.deep>=17) or @Mode<3
    group by #br.dck,#br.b_id,#br.plann, #br.ag_id,#br.dt, #br.tip, #br.BName, #br.factT, #br.SkipT, #br.Tara, 
      #br.Audit, #br.AdvOrd,  #br.NeudSpr, #br.LastSver, #br.LastSell, 
      #br.DayProd, #br.Debt, #br.Overdue, #br.Over17, #br.Deep,  
      #wp.WeekSell, #mp.MonthSell, #wm.WeekPay, #mm.MonthPay,A.DepID, A.sv_ag_id,P.Fio,
      #f.qty, def.gpAddr, #al.LastSverSVDate, #al.LastSverSVState, #PH.Photos, PA.Fio,#dp.todaysell, L.sweight, 
      L.FactLikvid, L.FactLikvidPcs,  L.FactBrak,  L.FactBrakPcs,
      L.PlanLikvidPCS
    order by A.sv_ag_id, ag_id, #br.bname, b_id;
    select top 1 * from guard.planexec where Comp=@Comp order by b_id;
  end;
*/

end;