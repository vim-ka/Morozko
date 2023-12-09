CREATE procedure Guard.PlanCompleteTys
as
declare @today datetime, @yesterday datetime, @TotalOver decimal(12,2)
begin
  set @today=dbo.today();
  set @yesterday=dateadd(day,-1,@today);

  -- Должники по состоянию на вечер вчерашнего дня:
  create table #OV(dck int, debt decimal(10,2), Over17 decimal(10,2), Deep int, LastSell datetime );  
  insert into #OV
    select s.dck, s.debt, s.OverUp17-isnull(E.Plata,0) as Overdue17, s.Deep, L.LastSell
    from 
      DailySaldoDck S 
      left join (select DCK,sum(plata) as Plata from Kassa1 where nd=@today and oper=-2 group by dck) E on e.dck=s.dck
      left join (select nc.dck, max(nc.nd) as LastSell 
        from nc where actn=0 and frizer=0 and tara=0 
        and nc.nd>=DATEADD(year,-1,@today) group by nc.dck) L on L.dck=S.dck
    where s.overup17>0 and s.Nd=@yesterday and s.OverUp17-isnull(E.Plata,0)>=0.50
  set @TotalOver=(select sum(over17) from #ov);

  print 'Суммарная просрочка более 17 дней по всем покупателям равна '+cast(round(@TotalOver/1000.0,3) as varchar)+' т.р.';
  
  -- Список покупателей:  
  create table #Br(depid int, sv_id int,  ag_id int,  b_id int, dt char(5), factT char(8), Tara int,
    Audit char(8), AdvOrd char(8), NeudSpr int, LastSver date, LastSell date, DayProd char(20), 
    Debt decimal(12,2), Overdue decimal(12,2), Deep int );
    
  -- Учтем сегодняшние продажи:
  create table #t(dck int,sell decimal(12,2));
  insert into #t select dck,sum(sp) as sell from nc where nd=@today and tara=0 and frizer=0 and actn=0 group by dck;
  update #ov set Debt=Debt+#t.sell from #ov inner join #t on #t.dck=#ov.dck;

  -- Возможно, сегодня были выплаты по каким-то должникам:
  create table #k(dck int, pay decimal(10,2))
  insert into #k select DCK, sum(plata) from Kassa1 k where nd=@today and oper=-2 group by dck;
  
  -- Скорректируем просрочку:
  update #ov set debt=debt-#k.pay,over17=over17-pay
  from #ov inner join #k on #k.dck=#ov.dck;
  delete from #ov where over17<=0.50
  drop table #t; drop table #k;  

  insert into #br(depid,sv_id,ag_id,b_id,Debt,Overdue,Deep,LastSell)
  select
    A.DepID, a.sv_ag_id as SV_ID, dc.ag_id, dc.pin as b_id, sum(#ov.debt) debt,
    sum(#ov.Over17) as OPverdue, max(#ov.deep) deep, max(#ov.LastSell)
  from 
    #ov
    inner join defcontract dc on dc.dck=#ov.dck
    inner join def on def.pin=dc.pin
    inner join Agentlist A on A.ag_id=dc.ag_id
  group by  
    A.DepID, a.sv_ag_id, dc.ag_id, dc.pin;


  select #br.*, deps.DName, def.brname,def.gpName, P.Fio as AgentFam, R.Fio as Superfam
  from #br 
    inner join deps on deps.depid=#br.depid 
    inner join Def on Def.pin=#br.b_id
    inner join agentlist A on A.ag_id=#br.ag_id inner join Person P on P.p_id=a.p_id
    inner join agentlist B on B.ag_id=#br.sv_id inner join Person R on R.p_id=b.p_id
    

  set @TotalOver=(select sum(overdue) from #br);
  print 'Суммарная просрочка (с учетом сегодняшних выплат) более 17 дней по всем покупателям равна '+cast(round(@TotalOver/1000.0,3) as varchar)+' т.р.';
    
  
END