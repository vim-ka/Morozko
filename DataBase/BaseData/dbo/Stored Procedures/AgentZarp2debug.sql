
CREATE procedure AgentZarp2debug @day0 datetime, @period int
as
declare @d00 datetime, @d01 datetime
declare @b_id int
declare @r money, @plata money, @plataIce money, @PlataPf money, @PlataOther money
declare @dohod money, @Dohod0i money, @Dohod0m money, @Dohod0o money
declare @dohodIce money, @DohodPf money, @DohodOther money
declare @sell0i money,  @Sell0o money,@Sell0m money
begin
  set @d00=@day0-2*@period
  set @d01=@day0-@period

  create table PLTMP(b_id int, 
    plata0 money default 0,  -- плата за все, кроме игнорируемых (напр., холодильников) 
      plata0i money default 0, -- плата за мороженое
      plata0m money default 0, -- плата за полуфабрикаты
      plata0o money default 0, -- плата за остальное
    plata1 money default 0,  -- всё за предыдущий период
    plata2 money default 0,  -- всё за пред-предыдущий период
    sell0 money default 0,   -- то же с продажей. Все за текущий период
    sell0i money default 0,
    sell0m money default 0,
    sell0o money default 0,
    sell1 money default 0,   -- всё за предыдущий период
    sell2 money default 0,   -- всё за пред-предыдущий период
    dohod0  money default 0, -- то же с доходом.
      dohod0i money default 0,
      dohod0m money default 0,
      dohod0o money default 0,
    dohod1 money default 0, 
    dohod2 money default 0
    );

  -- продажи за самый ранний период  :
  declare CURSELL cursor for 
    select b_id, sum(spIce+spPF+spOther) as Sell0 
    from NC 
    where ND between @d00 and @d00+@period-1 and frizer=0 and Actn=0 and Tara=0
    group by B_ID;
  open CURSELL;
  fetch next from CURSELL into @b_id,@r;
  while @@FETCH_STATUS = 0 begin
    insert into PLTMP(b_id,sell2) values(@b_id,@r);
    fetch next from CURSELL into @b_id,@r;
  end;
  close CURSELL;
  deallocate CURSELL;
  
  -- продажи за предпоследний период  :
  declare CURSELL cursor 
    for select b_id, sum(spIce+spPF+spOther) as Sell0 
    from NC 
    where ND between @d01 and @day0-1 and frizer=0 and Actn=0 and Tara=0
    group by B_ID;
  open CURSELL;
  fetch next from CURSELL into @b_id,@r;
  while @@FETCH_STATUS = 0 begin
    insert into PLTMP(b_id,sell1) values(@b_id,@r);
    fetch next from CURSELL into @b_id,@r;
  end;
  close CURSELL;
  deallocate CURSELL;
  
  -- продажи за последний период (более подробные, с разбивкой по группам мороженое-прочее-полуфабрикаты):
  declare CURSELL cursor for 
    select b_id, sum(spIce) as Sell0i,  sum(spOther) as Sell0o, sum(spPF) as Sell0m 
    from NC
    where ND between @day0 and @day0+@period-1 and frizer=0 and Actn=0 and Tara=0
    group by B_ID;
  open CURSELL;
  fetch next from CURSELL into @b_id,@sell0i,@Sell0o,@Sell0m;
  while @@FETCH_STATUS = 0 begin
    insert into PLTMP(b_id,sell0,sell0i,sell0o, sell0m) 
    values(@b_id,@sell0i+@sell0o+@Sell0m,  @sell0i, @Sell0o, @sell0m);
    fetch next from CURSELL into @b_id,@sell0i,@Sell0o,@Sell0m;
  end;
  close CURSELL;
  deallocate CURSELL;
  

  -- Выплата и доход за за самый ранний из трех периодов. 
  insert into PLTMP(B_ID, plata2, dohod2)
  select 
    K.B_ID, sum(K.Plata) as Plata2, 
    round(sum(case when (nc.sp=0 or nc.sp is null) then K.Plata else K.Plata*(nc.sp-nc.sc)/NC.sp END),2) as Dohod2
    from Kassa1 K, NC 
    where (K.ND between @d00 and @d00+@period-1) and K.Oper=-2 and K.Act='ВЫ'
    and NC.Datnom=K.SourDatnom and NC.Frizer=0 and NC.Actn=0 and NC.Tara=0
    group by K.B_ID;


  
  -- Выплата и доход за средний период
  insert into PLTMP(B_ID, plata1, dohod1)
  select 
    K.B_ID, sum(K.Plata) as Plata1, 
    round(sum(case when (nc.sp=0 or nc.sp is null) then K.Plata else K.Plata*(nc.sp-nc.sc)/NC.sp END),2) as Dohod1
    from Kassa1 K, NC 
    where (K.ND between @d01 and @d01+@period-1) and K.Oper=-2 and K.Act='ВЫ'
    and NC.Datnom=K.SourDatnom and NC.Frizer=0 and NC.Actn=0 and NC.Tara=0
    group by K.B_ID;
  
  -- За последний период считаем плату всего, плату отдельно за мороженое, 
  -- доход всего и отдельно доход от оплаты мороженого:    
  
  insert into PLTMP(B_ID, plata0i,plata0m,plata0o, dohod0i,dohod0m,dohod0o) 
  select 
    K.B_ID, 
    round(sum(case when nc.sp=0 then 0 else K.Plata*nc.SpIce/nc.SP END),2) as Plata0i,
    round(sum(case when nc.sp=0 then K.Plata else K.Plata*nc.SpPf/nc.SP END),2) as Plata0m,
    round(sum(case when nc.sp=0 then 0 else K.Plata*nc.SpOther/nc.SP END),2) as Plata0o,
    round(sum(case when nc.sp=0 then 0 else K.Plata*(nc.spIce-nc.scIce)/NC.sp END),2) as Dohod0i,
    round(sum(case when nc.sp=0 then 0.10*K.Plata else K.Plata*(nc.spPf-nc.scPF)/NC.sp END),2) as Dohod0m,
    round(sum(case when nc.sp=0 then 0 else K.Plata*(nc.spOther-nc.scOther)/NC.sp END),2) as Dohod0o
    from Kassa1 K, NC 
    where (K.ND between @day0 and @day0+@period-1) and K.Oper=-2 and K.Act='ВЫ' 
    and NC.Datnom=K.SourDatnom and NC.Frizer=0 and NC.Actn=0 and NC.Tara=0
    group by K.B_ID;  
  update PLTMP set 
    plata0=isnull(plata0i,0)+ISNULL(plata0o,0)+ISNULL(plata0m,0), 
    dohod0=isnull(dohod0i,0)+isnull(dohod0m,0)+isnull(dohod0m,0);
  
select 
  p.b_id, d.gpname, d.tip,d.brname, 
  sum(isnull(p.plata0,0)) plata0, 
    sum(isnull(p.plata0i,0)) plata0i,  
    sum(isnull(p.plata0m,0)) plata0m,  
    sum(isnull(p.plata0o,0)) plata0o,  
  sum(isnull(p.plata1,0)) plata1,
  sum(isnull(p.plata2,0)) plata2, 
  SUM(p.sell0i+p.sell0i+p.sell0m) sell0, 
    SUM(isnull(p.sell0i,0)) sell0i, 
    SUM(isnull(p.sell0m,0)) sell0m, 
    SUM(isnull(p.sell0o,0)) sell0o, 
  sum(isnull(p.sell1,0)) sell1, sum(isnull(p.sell2,0)) sell2,
  sum(p.dohod0i+p.dohod0m+p.dohod0o) dohod0, 
    sum(isnull(p.dohod0i,0)) as dohod0i, 
    sum(isnull(p.dohod0m,0)) as dohod0m,
    sum(isnull(p.dohod0o,0)) as dohod0o,  
  sum(isnull(p.dohod1,0)) dohod1, 
  sum(isnull(p.dohod2,0)) dohod2
from 
  pltmp p left outer join def d on d.pin=p.b_id
  where d.tip=1
  group by p.b_id, d.gpname, d.tip,d.brname
  order by p.b_id
end