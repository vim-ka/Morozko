CREATE PROCEDURE dbo.SkladPrepareSellCount_Debug @ag_id int, @Mode tinyint, @NeedDay datetime, @Comp varchar(30)
-- Mode=1-агент, 2-супервайзер, 3-Тыщик, 4-сводка по фирме
AS
declare @dn datetime, @today datetime, @yesterday datetime
BEGIN

  -- На выходе процедуры будут еще четыре поля: продажи с предыдущего воскресенья,
  -- т.е. это всегда за последние 1..7 дней, и также продажи за месяц,
  -- подразумевая продажи за период @NeedDay-29...@NeedDay включительно (за 30 дней),
  -- и еще количество холодильников на точке на момент прямо сейчас, 
  -- и количество сделанных фотографий за требуемый день.


  -- set STATISTICS time on;  
  set @dn = datepart(weekday, @NeedDay); -- день недели,1=понедельник
  set @today=dbo.today()
  set @yesterday=dateadd(day,-1,@today);
  
  
  -- cписок привязок агентов к развивающим:
  create table #ch(Ag_ID int, ChainAg_ID int);
  insert into #ch
    select ch.SourAG_ID, ch.ChainAg_Id 
    from guard.Chain ch
    where ch.day0<=@needday and (ch.day1 is null or ch.day1>=@needday);

  -- Список продаж:
  create table #pr(dck int, ag_id int, TmAgSell varchar(8) default '', TmOpSell varchar(8) default '');
  insert into #pr(dck,ag_id) 
  select distinct 
    nc.dck, nc.ag_id
  from nc 
  where nc.nd=@NeedDay and nc.refdatnom=0 and nc.Actn=0 and nc.sc>=0 and nc.remarkop not like 'w.%';

  print('Исходный #pr рассчитан за дату '+cast(@needday as varchar));
  -- select 'Исходный #pr' as Remark, * from #pr;

  -- Теперь считаем фактические продажи, сделанные агентами. Есть варианты: код агента можно взять или прямо из продаж, или
  -- из Defcontract. Причем этот код в любом случае может отличаться от плана посещений! Возьму из nc:

  update #pr set TmAgSell=isnull((select min(nc.tm) from NC 
    where nc.ag_id=#pr.ag_id and nc.Op>1000 and nc.dck=#pr.dck  and nc.remarkop not like 'w.%'
    and nc.sc>=0 and nc.nd=@NeedDay and nc.Actn=0),0);

  update #pr set TmOpSell=isnull((select min(nc.tm) from NC 
    where nc.ag_id=#pr.ag_id and nc.op<1000 and nc.dck=#pr.dck and nc.remarkop not like 'w.%'
    and nc.sc>=0 and nc.nd=@NeedDay and nc.Actn=0),'');

-- select 'Продажи' as Remark, * from #pr;

  -- Список полученных фотографий:
  create table #f(ag_id int, dck int, tm varchar(5));
  insert into #f 
  select fm.ag_id, fm.dck, dbo.fnMinutes2str(min(fp.savetmmn))
  from
    Guard.fmonitor fm
    inner join guard.fmonitorPics fp on fp.fmid=fm.fmid
  where fm.nd=@NeedDay
  group by fm.ag_id, fm.dck;
-- select 'Фото' as Remark, * from #f;

  -- Список инвентаризаций на точках за нужный день:
  create table #re(ag_id int, dck int, tm varchar(5));
  
  insert into #re 
	select ag_id, dck , min(left(convert(varchar, nd,108),5)) from rests where needday='20160711' group by ag_id, dck
-- select 'Остатки' as Remark, * from #re;

  -- Список оплат за нужный день:
  create table #py(ag_id int, dck int, tm varchar(5));
  
  insert into #py
  select dc.ag_id, k.dck, left(MIN(k.tm),5) as TM
  from 
    kassa1 k 
    inner join defcontract dc on dc.dck=k.dck
  where k.nd=@NeedDay and k.oper=-2 and k.remark not like 'компенсация%' and k.remark not like 'вычерк%' and k.remark not like 'возврат%'
  group by dc.ag_id, k.dck
-- select 'Плата' as Remark, * from #py;



  -- Список агентов:
  create table #Ag(ag_id int);
  -- это или один агент, или все агенты одного супервайзера:
  if @mode=1 insert into #ag values(@ag_id);
  else if @mode=2 insert into #ag(ag_id) select a.ag_id from agentlist a inner join person p on p.p_id=a.p_id where p.Closed=0 and a.sv_ag_id=@ag_id;
  else if @mode=4 insert into #ag(ag_id) select a.ag_id from agentlist a inner join person p on p.p_id=a.p_id where p.Closed=0;

-- SELECT 'Список агентов' as Remark, * from #ag;

  -- Идея такая: сооружаем таблицу для запланированных посещений
  create table #po(dck int, b_id int default 0, ag_id int, tmPlan varchar(5), -- tmPlan - запланированное время посещения
    Tip smallint,
    TmAgSell varchar(5) default '', tmPhoto varchar(5) default '', tmRest varchar(5) default '', 
    tmPay varchar(5) default '', TmOpSell varchar(5) default '',-- время продажи,фото,сброса остатков, платы, продажи оператором
    NeedDW1 tinyint default 0, NeedDW2 tinyint default 0,NeedDW3 tinyint default 0,NeedDW4 tinyint default 0,NeedDW5 tinyint default 0,NeedDW6 tinyint default 0,NeedDW7 tinyint default 0 -- планы посещений по дням недели
    )

  -- и заполняем поле PLAN данными из таблицы планирования:
  insert into #Po(dck,ag_id)
    select pv.dck, pv.ag_id from PlanVisit2 pv where pv.dn=@dn
    union
    select distinct dck,ag_id from #pr
    union
    select distinct dck,ag_id from #f
    union
    select distinct dck,ag_id from #re
    union
    select distinct dck,ag_id from #py
    ;

  update #po set NeedDW1=1 from #po inner join Planvisit2 p on p.ag_id=#po.ag_id and p.dck=#po.dck and p.dn=1;    
  update #po set NeedDW2=1 from #po inner join Planvisit2 p on p.ag_id=#po.ag_id and p.dck=#po.dck and p.dn=2;    
  update #po set NeedDW3=1 from #po inner join Planvisit2 p on p.ag_id=#po.ag_id and p.dck=#po.dck and p.dn=3;    
  update #po set NeedDW4=1 from #po inner join Planvisit2 p on p.ag_id=#po.ag_id and p.dck=#po.dck and p.dn=4;    
  update #po set NeedDW5=1 from #po inner join Planvisit2 p on p.ag_id=#po.ag_id and p.dck=#po.dck and p.dn=5;    
  update #po set NeedDW6=1 from #po inner join Planvisit2 p on p.ag_id=#po.ag_id and p.dck=#po.dck and p.dn=6;    
  update #po set NeedDW7=1 from #po inner join Planvisit2 p on p.ag_id=#po.ag_id and p.dck=#po.dck and p.dn=7;    
 
  update #Po set tmplan=dbo.fnMinutes2str(pv.tm), #po.Tip=pv.tip
  from 
  	#po 
    inner join PlanVisit2 pv on pv.ag_id=#po.ag_id and pv.dck=#Po.dck and pv.dn=@dn;
    -- inner join #ag on #ag.ag_id=pv.ag_id and pv.dn=@dn;
    
-- SELECT 'План' as Remark, * from #po where ag_id=798;
  
  update #po set TmAgSell=left(#pr.TmAgSell,5) from #po inner join #pr on #pr.ag_id=#po.ag_id and #pr.dck=#po.dck;
  update #po set TmOpSell=left(#pr.TmOpSell,5) from #po inner join #pr on #pr.ag_id=#po.ag_id and #pr.dck=#po.dck;
  update #po set TmPhoto=#f.tm from #po inner join #f on #f.ag_id=#po.ag_id and #f.dck=#po.dck;
  update #po set TmRest=#re.tm from #po inner join #re on #re.ag_id=#po.ag_id and #re.dck=#po.dck;
  update #po set TmPay=#py.tm from #po inner join #py on #py.ag_id=#po.ag_id and #py.dck=#po.dck;
  update #Po set tmplan='' where tmplan is null;
  update #Po set tmAgSell='' where tmAgSell='0';
  


  --  insert into #po(dck,ag_id,tmplan) 
  --  select pv.dck, pv.ag_id, dbo.fnMinutes2str(pv.tm) as tmPlan
  --  from PlanVisit2 pv inner join #ag on #ag.ag_id=pv.ag_id and pv.dn=@dn;

    
-- SELECT 'План+факт' as Remark,  dc.pin, def.gpname,#po.*
-- from #po 
-- inner join defcontract dc on dc.dck=#po.dck
--   inner join def on def.pin=dc.pin;

update #po set tmplan='z' where tmplan='';
update #po set TmAgSell='z' where TmAgSell='';
update #po set tmPhoto='z' where tmPhoto='';
update #po set tmRest='z' where tmRest='';
update #po set tmPay='z' where tmPay='';
update #po set TmOpSell='z' where TmOpSell='';
update #po set b_id=dc.pin from #po inner join Defcontract dc on dc.dck=#po.dck;

if @Mode=1 
  select E.*, pvt.Shortname as StrTip
  from (
    select
    #po.ag_id, '' as Ag_Fam, dc.pin, def.gpname, 
    iif(min(#po.tmPlan)='z','', min(#po.tmPlan)) as tmPlan,
    isnull(min(#po.tip),0) as Tip, 
    iif(min(#po.TmAgSell)='z','',min(#po.TmAgSell)) tmAgSell,
    iif(min(#po.tmPhoto)='z','',min(#po.tmPhoto)) tmPhoto,
    iif(min(#po.tmRest)='z','',min(#po.tmRest)) tmRest,
    iif(min(#po.tmPay)='z','',min(#po.tmPay)) tmPay,
    iif(min(#po.tmOpSell)='z','',min(#po.tmOpSell)) tmOpSell,
    iif(sum(#po.NeedDW1)=0, cast(0 as bit), cast(1 as bit)) NeedW1,
    iif(sum(#po.NeedDW2)=0, cast(0 as bit), cast(1 as bit)) NeedW2,
    iif(sum(#po.NeedDW3)=0, cast(0 as bit), cast(1 as bit)) NeedW3,
    iif(sum(#po.NeedDW4)=0, cast(0 as bit), cast(1 as bit)) NeedW4,
    iif(sum(#po.NeedDW5)=0, cast(0 as bit), cast(1 as bit)) NeedW5,
    iif(sum(#po.NeedDW6)=0, cast(0 as bit), cast(1 as bit)) NeedW6,
    iif(sum(#po.NeedDW7)=0, cast(0 as bit), cast(1 as bit)) NeedW7, 
    PC.Comment, 0 as ChainAg_ID, '' as ChainFam
  from 
    #po
    inner join defcontract dc on dc.dck=#po.dck
    inner join def on def.pin=dc.pin
    left join Guard.PlanComments PC on PC.nd=@NeedDay and Pc.ag_id=#po.ag_id and pc.b_id=dc.pin
    where #po.ag_id=@ag_id
  group by #po.ag_id, dc.pin, def.gpname, PC.Comment 
  ) E
  left join guard.PlanVisitTip pvt on pvt.tip=E.tip
  order by ag_id, gpname;
else if @Mode=2
  select E.*, pvt.Shortname as StrTip
  from (
    select
    #po.ag_id, left(P.Fio,50) as ag_Fam, dc.pin, def.gpname, 
    iif(min(#po.tmPlan)='z','', min(#po.tmPlan)) as tmPlan,
    isnull(min(#po.tip),0) as Tip, 
    iif(min(#po.TmAgSell)='z','',min(#po.TmAgSell)) tmAgSell,
    iif(min(#po.tmPhoto)='z','',min(#po.tmPhoto)) tmPhoto,
    iif(min(#po.tmRest)='z','',min(#po.tmRest)) tmRest,
    iif(min(#po.tmPay)='z','',min(#po.tmPay)) tmPay,
    iif(min(#po.tmOpSell)='z','',min(#po.tmOpSell)) tmOpSell,
    iif(sum(#po.NeedDW1)=0, cast(0 as bit), cast(1 as bit)) NeedW1,
    iif(sum(#po.NeedDW2)=0, cast(0 as bit), cast(1 as bit)) NeedW2,
    iif(sum(#po.NeedDW3)=0, cast(0 as bit), cast(1 as bit)) NeedW3,
    iif(sum(#po.NeedDW4)=0, cast(0 as bit), cast(1 as bit)) NeedW4,
    iif(sum(#po.NeedDW5)=0, cast(0 as bit), cast(1 as bit)) NeedW5,
    iif(sum(#po.NeedDW6)=0, cast(0 as bit), cast(1 as bit)) NeedW6,
    iif(sum(#po.NeedDW7)=0, cast(0 as bit), cast(1 as bit)) NeedW7, 
    PC.Comment, 0 as ChainAg_ID, '' as ChainFam
  from 
    #po
    inner join defcontract dc on dc.dck=#po.dck
    inner join def on def.pin=dc.pin
    inner join Agentlist A on a.ag_id=#po.ag_id
    inner join Person P on P.p_id=a.P_ID
    left join Guard.PlanComments PC on PC.nd=@NeedDay and Pc.ag_id=#po.ag_id and pc.b_id=dc.pin
  where A.sv_ag_id=@ag_id
  group by
    #po.ag_id, left(P.Fio,50), dc.pin, def.gpname, PC.Comment
  ) E
  left join guard.PlanVisitTip pvt on pvt.tip=E.tip
  order by ag_id, gpname;

else if @mode=4 begin
  update #po set tip=0 where tip is null;

--  select 
--    Sv.DepID, Deps.dname, A.sv_ag_id, PS.Fio as SuperFam,  
--    #po.DCK, #po.AG_ID, Pa.Fio as AgentFam,  #po.tmPlan,#po.TIP,#po.TmAgSell,#po.tmPhoto,#po.tmRest,#po.tmPay,#po.TmOpSell 
--  from 
--    #po
--    inner join Agentlist A on A.AG_ID=#po.ag_id
--    inner join Person PA on PA.p_id=A.P_ID
--    inner join Agentlist SV on SV.AG_ID=A.sv_ag_id
--    inner join Person PS on PS.P_ID=SV.p_id
--    left join Deps on Deps.DepID=sv.DepID
--  WHERE
--    sv.DepID>0
--    and a.sv_ag_id=513
--  order by sv.DepID, A.sv_ag_id;

  -- Сворачиваю таблицу #po, исключая поле dck:
  create table #po2(b_id int default 0, ag_id int, tmPlan varchar(5), -- tmPlan - запланированное время посещения
    Tip smallint,
    TmAgSell varchar(5) default '', tmPhoto varchar(5) default '', tmRest varchar(5) default '', 
    tmPay varchar(5) default '', TmOpSell varchar(5) default '',-- время продажи,фото,сброса остатков, платы, продажи оператором
    NeedDW1 tinyint default 0, NeedDW2 tinyint default 0,NeedDW3 tinyint default 0,NeedDW4 tinyint default 0,NeedDW5 tinyint default 0,NeedDW6 tinyint default 0,NeedDW7 tinyint default 0 -- планы посещений по дням недели
    );

  insert into #po2 
    select b_id,ag_id,min(tmPlan),min(tip),
    min(tmAgSell),min(tmPhoto),min(tmRest),min(tmPay),min(tmOpSell),
    max(NeedDW1),max(NeedDW2),max(NeedDW3),max(NeedDW4),max(NeedDW5),max(NeedDW6),max(NeedDW7)
  from #po
    group by b_id,ag_id;
  
  --  select #po2.* from 
  --    Agentlist A
  --    left join #po2 on #po2.ag_id=A.AG_ID
  --  where A.AG_ID=556;


  select 
    Sv.DepID, Deps.dname, 
    A.sv_ag_id, PS.Fio as SuperFam, 
    a.ag_id, Pa.Fio as AgentFam, 
    sum(iif(tmPlan='z' or tmplan is null,0,1)) as CountPlan,
    sum(iif(tmAgSell='z' or tmAgSell is null,0,1)) as CountAgSell,
    sum(iif(tmPhoto='z' or tmphoto is null,0,1)) as CountPhoto,
    sum(iif(tmRest='z' or tmRest is null,0,1)) as CountRest,
    sum(iif(tmPay='z' or tmpay is null,0,1)) as CountPay,
    sum(iif(tmOpSell='z' or tmopSell is null,0,1)) as CountOpSell,
    sum(iif( #po2.tmPlan='z' or #po2.tmPlan is null or (#po2.Tip<>6 and tmAgSell='z' and tmPhoto='z' and tmRest='z'and tmPay='z') ,0,1)) as TotalCount,
    #ch.ChainAg_ID, PC.Fio as ChainFam
  from 
    Agentlist A 
    left join #po2 on #po2.ag_id=A.AG_ID
    inner join Person PA on PA.p_id=A.P_ID
    inner join Agentlist SV on SV.AG_ID=A.sv_ag_id
    inner join Person PS on PS.P_ID=SV.p_id
    left join Deps on Deps.DepID=sv.DepID
    left join #ch on #ch.ag_id=A.ag_id
    left join Agentlist as Dev on Dev.AG_ID=#ch.ChainAg_ID
    left join Person PC on PC.P_ID=Dev.P_ID
  WHERE
    sv.DepID>0
    and deps.Sale=1
    and pa.Invis=0
    and pa.Closed=0
  group by Sv.DepID, Deps.dname, a.ag_id, PA.Fio, A.sv_ag_id, PS.Fio, #ch.ChainAg_ID, PC.Fio
  order by sv.DepID, A.sv_ag_id, pa.Fio




--  select 
--    Sv.DepID, Deps.dname, A.sv_ag_id, PS.Fio as SuperFam,  
--    #po.DCK, #po.AG_ID,  #po.tmPlan,#po.TIP,#po.TmAgSell,#po.tmPhoto,#po.tmRest,#po.tmPay,#po.TmOpSell 
--  from 
--    #po
--    inner join Agentlist A on A.AG_ID=#po.ag_id
--    inner join Agentlist SV on SV.AG_ID=A.sv_ag_id
--    inner join Person PS on PS.P_ID=SV.p_id
--    left join Deps on Deps.DepID=sv.DepID
--  WHERE
--    sv.DepID>0
--    and a.sv_ag_id=513
--    and iif( #po.tmPlan='z' or (#po.Tip<>6 and tmAgSell='z' and tmPhoto='z' and tmRest='z'and tmPay='z') ,0,1)=1;
  
--  select 
--    Sv.DepID, Deps.dname, A.sv_ag_id, PS.Fio as SuperFam,  
--    #po.DCK, #po.AG_ID, Pa.Fio as AgentFam,  #po.tmPlan,#po.TIP,#po.TmAgSell,#po.tmPhoto,#po.tmRest,#po.tmPay,#po.TmOpSell 
--  from 
--    #po
--    inner join Agentlist A on A.AG_ID=#po.ag_id
--    inner join Person PA on PA.p_id=A.P_ID
--    inner join Agentlist SV on SV.AG_ID=A.sv_ag_id
--    inner join Person PS on PS.P_ID=SV.p_id
--    left join Deps on Deps.DepID=sv.DepID
--  WHERE
--    sv.DepID>0
--    -- and a.sv_ag_id=513
--    and iif( #po.tmPlan='z' or (#po.Tip<>6 and tmAgSell='z' and tmPhoto='z' and tmRest='z'and tmPay='z') ,0,1)=0;

end;


-- select * from #po;
set STATISTICS time off;  

END