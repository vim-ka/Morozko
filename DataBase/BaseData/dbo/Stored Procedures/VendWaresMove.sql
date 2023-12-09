CREATE PROCEDURE VendWaresMove
  @Ncod int, @Dck int=0, @day0 datetime, @day1 datetime
as

begin
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
  
  Declare @StartSaldo decimal(12,2), @ND datetime,@TIM varchar(8),@Plata decimal(12,2),
    @SumCost decimal(12,2),@Izmen decimal(12,2),
    @Corr decimal(12,2), @Remove decimal(12,2), @Bank INT, 
    @aid smallint,@saldo1 decimal(12,2),@saldo2 decimal(12,2);
  


  create table #T (ND datetime, Plata decimal(12,2) default 0,
    SumCost decimal(12,2), Izmen decimal(12,2) default 0,
    Corr decimal(12,2) default 0, Remove decimal(12,2) default 0, aid smallint)
                           
  create table #ResTable (ND datetime,TIM varchar(8),Plata decimal(12,2),Remark varchar(100),SumCost decimal(12,2),Izmen decimal(12,2),
                           Corr decimal(12,2), Remove decimal(12,2), Bank INT, My int,nomdok varchar(30),
                           OP INT, mid int, aid smallint,saldo1 decimal(12,2),saldo2 decimal(12,2))
                           
  Declare @CURSOR Cursor                          

  if @DCK=0 begin
    set @StartSaldo=isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and c2.date<@day0),0) 
             +isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and cc2.nd<@day0),0) 
             -isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and oper=-1 and k2.nd<@day0),0)
             +isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and (i2.Act='Снят' or i2.Act='ИзмЦ') and i2.nd<@day0),0);

    insert into #T(ND,Plata,SumCost,Izmen,Corr,Remove,aid)                        
      select k.nd Data, sum(k.Plata) Plata,  0 sumcost, 0 izmen, 0 corr, 0 remove,3 aid
      from kassa1 k
      where k.ncod=@ncod and k.nd>=@day0 and k.nd<@day1 and k.oper=-1
      group by k.nd
      UNION

      select c.date ND, 0 Plata, sum(c.summacost) sumcost, 0 izmen, 0 corr, 0 remove,4 aid
      from comman c
      where c.ncod=@ncod and c.date>=@day0 and c.date<@day1
      group by C.Date

      UNION
      
      select dateadd(day, datediff(day,0,cc.nd),0) ND, 0 Plata,
      0 sumcost, 0 izmen, sum(cc.corr) corr, 0 remove, 2 aid
      from commancorr cc,comman cm
      where cc.ncom=cm.ncom and cm.ncod=@ncod and cc.Nd>=@day0 and cc.Nd<@day1
      group by dateadd(day, datediff(day,0,cc.nd),0)

      UNION

      select i.ND Data, 0 Plata,  0 sumcost, 0 izmen, 0 corr, sum(i.smi) remove,  1 aid
      from izmen i
      where i.ncod=@ncod and i.Nd>=@day0 and i.Nd<@day1 and i.Act='Снят' and i.smi<>0
      group by i.ND

      UNION

      select i.ND Data, 0 Plata, 0 sumcost, sum(i.smi) izmen, 0 corr, 0 remove, 0 aid
      from izmen i
      where i.ncod=@ncod and i.Nd>=@day0 and i.Nd<@day1 and i.Act='ИзмЦ' and i.smi<>0
      group by i.ND
      order by ND;
    
    
/*

    set @CURSOR  = Cursor scroll
    for select * from #TempTable order by ND

    open @CURSOR

    fetch next from @CURSOR into @ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                      @Corr, @Remove, @Bank, @My,@nomdok,@OP,@mid,@aid
    set @saldo1=@saldo                
    if (@SumCost is not null) set @saldo2=@saldo1+@SumCost
    else if (@Plata is not null) set @saldo2=@saldo1-@Plata 
    else if (@Remove is not null) set @saldo2=@saldo1+@Remove            
    else if (@Izmen is not null) set @saldo2=@saldo1+@Izmen            
    else if (@Corr is not null) set @saldo2=@saldo1+@Corr                       

    while @@FETCH_STATUS = 0
    begin
      insert into #ResTable (ND,TIM,Plata,Remark,SumCost,Izmen,
                             Corr, Remove, Bank, My,nomdok,
                             OP, mid, aid,saldo1,saldo2)
                     values (@ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                             @Corr, @Remove, @Bank, @My,@nomdok,
                             @OP, @mid, @aid,@saldo1,@saldo2)
      
      fetch next from @CURSOR into @ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                                      @Corr, @Remove, @Bank, @My,@nomdok,@OP,@mid,@aid
      set @saldo1=@saldo2                                 
                      
      if (@SumCost is not null) set @saldo2=@saldo1+@SumCost
      else if (@Plata is not null) set @saldo2=@saldo1-@Plata 
      else if (@Remove is not null) set @saldo2=@saldo1+@Remove            
      else if (@Izmen is not null) set @saldo2=@saldo1+@Izmen            
      else if (@Corr is not null) set @saldo2=@saldo1+@Corr
    end
      
    close @CURSOR
      
    select * from #ResTable order by ND
    */
  end
/*
  else
  begin

    set @saldo=isnull((select sum(c2.summacost) from comman c2 where c2.ncod=@ncod and c2.dck=@dck and c2.date<@day0),0) 
               +isnull((select sum(cc2.corr) from commancorr cc2, comman c2 where cc2.ncom=c2.ncom and c2.ncod=@ncod and c2.dck=@dck and cc2.nd<@day0),0) 
               -isnull((select sum(k2.plata) from kassa1 k2 where k2.ncod=@ncod and k2.dck=@dck and oper=-1 and k2.nd<@day0),0)
               +isnull((select sum(i2.smi) from izmen i2 where i2.ncod=@ncod and i2.dck=@dck and (i2.Act='Снят' or i2.Act='ИзмЦ') and i2.nd<@day0),0)

    insert into #TempTable (ND,TIM,Plata,Remark,SumCost,Izmen,Corr,Remove,Bank,My,nomdok,
                            OP,mid,aid)                        

    select k.nd Data, max(k.tm) TIM, sum(k.Plata) Plata, max(k.Remark) Remark,
    null sumcost, null izmen, null corr, null remove,
    k.Bank_id bank, null My, null nomdok,k.op OP, max(k.kassid) mid, 3 aid
    from kassa1 k
    where k.ncod = @ncod and k.dck = @dck and k.nd >= @day0 and k.nd < @day1
          and k.oper = -1
    group by k.nd,k.bank_id,k.op

    union

    select c.date Data, c.time TIM, null Plata, 'Приход - срок конс. '+convert(varchar(4),srok)+' дней' Remark,
    c.summacost sumcost, null izmen, null corr, null remove,
    null bank, our_id My, c.doc_nom nomdok,c.op OP, c.ncom mid, 4 aid
    from comman c
    where c.ncod = @ncod and c.dck = @dck and c.date >= @day0 and c.date < @day1

    union

    select cast(floor(cast(cc.nd as decimal(38,19))) as datetime) Data, convert(varchar(8),cc.nd,108) TIM, null Plata,cc.Remark,
    Null sumcost, null izmen, cc.corr corr, null remove,
    null bank, null My, null nomdok,cc.op OP, cc.ncom mid, 2 aid
    from commancorr cc,comman cm
    where cc.ncom=cm.ncom and cm.ncod = @ncod and cm.dck = @dck and cc.Nd >= @day0 and cc.Nd < @day1

    union

    select i.ND Data, max(i.tm) TIM, null Plata, max(i.Remark) Remark,
    Null sumcost, Null izmen, null corr, sum(i.smi) remove,
    null bank, null My, null nomdok,i.op OP, null mid, 1 aid
    from izmen i
    where i.ncod = @ncod and i.dck = @dck and i.Nd >= @day0 and i.Nd < @day1
          and i.Act='Снят' and i.smi<>0
    group by i.ND,i.OP

    union

    select i.ND Data, max(i.tm) TIM, null Plata, max(i.Remark) Remark,
    Null sumcost, sum(i.smi) izmen, null corr, null remove,
    null bank, null My, null nomdok,i.op OP, null mid, 0 aid
    from izmen i
    where i.ncod = @ncod and i.dck = @dck and i.Nd >= @day0 and i.Nd < @day1
          and i.Act='ИзмЦ' and i.smi<>0
    group by i.ND,i.OP
    order by 1,2,14

    set @CURSOR  = Cursor scroll
    for select * from #TempTable order by ND
    open @CURSOR
    fetch next from @CURSOR into @ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                      @Corr, @Remove, @Bank, @My,@nomdok,@OP,@mid,@aid
    set @saldo1=@saldo                
    if (@SumCost is not null) set @saldo2=@saldo1+@SumCost
    else if (@Plata is not null) set @saldo2=@saldo1-@Plata 
    else if (@Remove is not null) set @saldo2=@saldo1+@Remove            
    else if (@Izmen is not null) set @saldo2=@saldo1+@Izmen            
    else if (@Corr is not null) set @saldo2=@saldo1+@Corr                       

    while @@FETCH_STATUS = 0
    begin
      insert into #ResTable (ND,TIM,Plata,Remark,SumCost,Izmen,
                             Corr, Remove, Bank, My,nomdok,
                             OP, mid, aid,saldo1,saldo2)
                     values (@ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                             @Corr, @Remove, @Bank, @My,@nomdok,
                             @OP, @mid, @aid,@saldo1,@saldo2)
      
      fetch next from @CURSOR into @ND,@TIM,@Plata,@Remark,@SumCost,@Izmen,
                                      @Corr, @Remove, @Bank, @My,@nomdok,@OP,@mid,@aid
      set @saldo1=@saldo2                                 
                      
      if (@SumCost is not null) set @saldo2=@saldo1+@SumCost
      else if (@Plata is not null) set @saldo2=@saldo1-@Plata 
      else if (@Remove is not null) set @saldo2=@saldo1+@Remove            
      else if (@Izmen is not null) set @saldo2=@saldo1+@Izmen            
      else if (@Corr is not null) set @saldo2=@saldo1+@Corr
    end
      
    close @CURSOR
      
    select * from #ResTable  order by ND 

  end
  */
















  -- Остатки в рублях и кг на вечер каждого дня, начиная с @Day0-1:
  create table #r(Workdate datetime, RestSC decimal(12,2), RestSP decimal(12,2), RestWeight decimal(12,3));

  insert into #r select A.WorkDate, sum(a.EveningRest*a.cost), sum(a.EveningRest*a.Price), 
    sum(a.EveningRest*iif(a.Weight>0,a.WEIGHT,NM.netto))
  from MorozArc..ArcVI A
    inner join Nomen NM on NM.Hitag=a.Hitag
  where a.WorkDate between dateadd(day, -1, @day0) and @day1
  and ((@dck=0 and a.Ncod=@Ncod) or (@dck>0 and a.Dck=@Dck))
  group by a.WorkDate;

  -- Начальный и конечный остаток в результирующей таблице:
  create table #M(ND datetime, 
    StartSC decimal(12,2) default 0,  StartSP decimal(12,2) default 0,  StartWeight decimal(12,3) default 0,
    IncomeSC decimal(12,2) default 0, IncomeSP decimal(12,2) default 0, IncomeWeight decimal(12,3) default 0,
    OutcomeSC decimal(12,2) default 0,OutcomeSP decimal(12,2) default 0,OutcomeWeight decimal(12,3) default 0,
    FinalSC decimal(12,2),  FinalSP decimal(12,2),  FinalWeight decimal(12,3),
    Saldo decimal(12,2), Overdue decimal(12,2), OurPay decimal(12,2)
    );
  insert into #M(ND) select distinct ND from kassahro where nd between @day0 and @day1;

  update #M set StartSC=#r.RestSc, StartSP=#r.RestSP, StartWeight=#r.RestWeight
  from #m
  inner join #r on #r.WorkDate=dateadd(day,-1, #m.nd);
  
  update #M set FinalSC=#r.RestSc, FinalSP=#r.RestSP, FinalWeight=#r.RestWeight
  from #m
  inner join #r on #r.WorkDate=#m.nd;
  

  -- Приход от поставщиков за каждый день:
  update #M set IncomeSC=E.IncomeSC, IncomeSP=E.IncomeSP,  IncomeWeight=E.IncomeWeight
  from #M inner join ( select
      cm.[date] as ND, sum(i.kol*i.cost) as IncomeSC,
      sum(i.kol*i.Price) as IncomeSP,
      sum(i.kol*iif(isnull(i.[weight],0)>0,i.[weight], nm.Netto)) as IncomeWeight
    from 
      Comman cm 
      inner join Inpdet i on i.ncom=cm.Ncom
      left join Nomen NM on NM.hitag=i.hitag
    where 
      Cm.[date] between @day0 and @day1
      and ((@dck=0 and cm.Ncod=@Ncod) or (@dck>0 and cm.Dck=@Dck))
    group by cm.[date]
  ) E on E.ND=#m.ND;
  
  -- Продажи покупателям день за днем. Возвраты от покупателя уменьшают продажи:
  update #M set OutcomeSC=E.OutcomeSC, OutcomeSP=E.OutcomeSP,  OutcomeWeight=E.OutcomeWeight
  from #M inner join ( select
      nc.ND, 
      sum(nv.kol*nv.cost) as OutcomeSC,
      sum(nv.kol*nv.Price*(1.0+nc.extra/100.0)) as OutcomeSp,
      sum(nv.Kol*iif(v.weight=0, nm.netto, v.weight)) as OutcomeWeight
    from 
      NC
      inner join nv on nv.datnom=nc.datnom
      inner join Visual V on V.ID=nv.tekid
      left join Nomen NM on NM.Hitag=nv.Hitag
    where 
      NC.nd between @day0 and @day1
      and ((@dck=0 and v.Ncod=@Ncod) or (@dck>0 and v.Dck=@Dck))
    group by nc.nd
  ) E on E.ND=#m.ND;


  -- возврат поставщику. Записывается в расходы:
  update #m 
  set 
    OutcomeSC=OutcomeSC+isnull(E.SC,0), 
    OutcomeSP=OutcomeSP+isnull(E.SP,0),  
    OutcomeWeight=OutcomeWeight+isnull(E.SW,0)
  FROM
    #m
    inner join ( select i.nd, 
 	  sum((i.kol-i.newkol)*i.cost*iif(i.act='Снят',1,-1)) as SC,
 	  sum((i.kol-i.newkol)*i.price*iif(i.act='Снят',1,-1)) as SP,
 	  sum((i.kol-i.newkol)*iif(v.weight>0,v.weight,nm.netto)*iif(i.act='Снят',1,-1)) as SW
      from 
        Izmen i
        inner join visual v on v.id=i.id
        inner join nomen nm on NM.hitag=i.hitag
      where
        i.act in ('Снят','Испр')
        and i.nd between @day0 and @day1
        and ((@dck=0 and i.Ncod=@Ncod) or (@dck>0 and i.Dck=@Dck))
      group by i.nd
    ) E  on E.ND=#m.ND;

  -- Операция разбиения div-. Расход по исходной строке:
  update #m 
  set 
    OutcomeSC=OutcomeSC+isnull(E.SC,0), 
    OutcomeSP=OutcomeSP+isnull(E.SP,0),  
    OutcomeWeight=OutcomeWeight+isnull(E.SW,0)
  FROM
    #m
    inner join ( select i.nd, 
 	  sum((i.kol-i.newkol)*i.cost) as SC,
 	  sum((i.kol-i.newkol)*i.price) as SP,
 	  sum((i.kol-i.newkol)*iif(v.weight>0,v.weight,nm.netto)) as SW
      from 
        Izmen i
        inner join visual v on v.id=i.id
        inner join nomen nm on NM.hitag=i.hitag
      where
        i.act='div-'
        and i.nd between @day0 and @day1
        and ((@dck=0 and i.Ncod=@Ncod) or (@dck>0 and i.Dck=@Dck))
      group by i.nd
    ) E  on E.ND=#m.ND;

  -- Операция слияния div+. Отрицательный расход по новой строке:
  update #m 
  set 
    OutcomeSC=OutcomeSC+isnull(E.SC,0), 
    OutcomeSP=OutcomeSP+isnull(E.SP,0),  
    OutcomeWeight=OutcomeWeight+isnull(E.SW,0)
  FROM
    #m
    inner join ( select i.nd, 
 	  sum((i.kol-i.newkol)*i.cost) as SC,
 	  sum((i.kol-i.newkol)*i.price) as SP,
 	  sum((i.kol-i.newkol)*iif(v.weight>0,v.weight,nm.netto)) as SW
      from 
        Izmen i
        inner join visual v on v.id=i.newid
        inner join nomen nm on NM.hitag=i.hitag
      where
        i.act='div+'
        and i.nd between @day0 and @day1
        and ((@dck=0 and i.Ncod=@Ncod) or (@dck>0 and i.Dck=@Dck))
      group by i.nd
    ) E  on E.ND=#m.ND;

  -- Операция TRAN. Расход по исходной строке:
  update #m 
  set 
    OutcomeSC=OutcomeSC+isnull(E.SC,0), 
    OutcomeSP=OutcomeSP+isnull(E.SP,0),  
    OutcomeWeight=OutcomeWeight+isnull(E.SW,0)
  FROM
    #m
    inner join ( select i.nd, 
 	  sum(i.kol*i.cost) as SC,
 	  sum(i.kol*i.price) as SP,
 	  sum(i.kol*iif(v.weight>0,v.weight,nm.netto)) as SW
      from 
        Izmen i
        inner join visual v on v.id=i.id
        inner join nomen nm on NM.hitag=i.hitag
      where
        i.act='tran'
        and i.nd between @day0 and @day1
        and ((@dck=0 and i.Ncod=@Ncod) or (@dck>0 and i.Dck=@Dck))
      group by i.nd
    ) E  on E.ND=#m.ND;

  -- Та же операция TRAN. Отрицательный расход по новой строке:
  update #m 
  set 
    OutcomeSC=OutcomeSC+isnull(E.SC,0), 
    OutcomeSP=OutcomeSP+isnull(E.SP,0),  
    OutcomeWeight=OutcomeWeight+isnull(E.SW,0)
  FROM
    #m
    inner join ( select i.nd, 
 	  sum(-i.newkol*i.cost) as SC,
 	  sum(-i.newkol*i.price) as SP,
 	  sum(-i.newkol*iif(v.weight>0,v.weight,nm.netto)) as SW
      from 
        Izmen i
        inner join visual v on v.id=i.newid
        inner join nomen nm on NM.hitag=i.newhitag
      where
        i.act='tran'
        and i.nd between @day0 and @day1
        and ((@dck=0 and i.Ncod=@Ncod) or (@dck>0 and i.Dck=@Dck))
      group by i.nd
    ) E  on E.ND=#m.ND;

  update #m set 
    Saldo=@StartSaldo + isnull((select sum(sumcost-plata+izmen+corr+remove) from #t where #t.nd<=#m.nd),0),
    OurPay=isnull((select sum(plata) from #t where #t.nd=#m.nd),0);    

  select * from #m order by nd;
  
  
  
  
  
/*  
  

  -- Начальное сальдо (на утро первого дня в периоде):
  set @StartSaldo=isnull((select SUM(SummaCost) from comman where Ncod=@Ncod and [date]<@day0));
  
    
-- Сальдо на вечер каждого дня в заданном периоде:
    
    

  select * from #m order by nd;
  */
end;