CREATE procedure AgentZarp @day0 datetime, @period int
as
declare @d00 datetime, @d01 datetime
declare @b_id int
declare @r money, @plata money, @plataIce money, @dohod money, @dohodIce money, @sell0i money
begin
  set @d00=@day0-2*@period
  set @d01=@day0-@period
  create table #PLTMP(b_id int, 
    plata0 money default 0, plata0i money default 0, plata1 money default 0, plata2 money default 0,
    sell0 money default 0, sell0i money default 0,
    sell1 money default 0, sell2 money default 0,
    dohod0  money default 0, dohod1 money default 0, dohod2 money default 0,
    dohod0i money default 0, dohod0m money default 0   
    );

  -- продажи за самый ранний период  :
  declare CURSELL cursor for select b_id, sum(sp) as Sell0 from NC 
    where ND between @d00 and @d00+@period-1 and frizer=0 and Actn=0 and Tara=0
    group by B_ID;
  open CURSELL;
  fetch next from CURSELL into @b_id,@r;
  while @@FETCH_STATUS = 0 begin
    insert into #PLTMP(b_id,sell2) values(@b_id,@r);
    fetch next from CURSELL into @b_id,@r;
  end;
  close CURSELL;
  deallocate CURSELL;
  
  -- продажи за самый предпоследний период  :
  declare CURSELL cursor for select b_id, sum(sp) as Sell0 from NC 
    where ND between @d01 and @day0-1 and frizer=0 and Actn=0 and Tara=0
    group by B_ID;
  open CURSELL;
  fetch next from CURSELL into @b_id,@r;
  while @@FETCH_STATUS = 0 begin
    insert into #PLTMP(b_id,sell1) values(@b_id,@r);
    fetch next from CURSELL into @b_id,@r;
  end;
  close CURSELL;
  deallocate CURSELL;
  
  -- продажи за последний период  :
  declare CURSELL cursor for select b_id, sum(sp) as Sell0, sum(spIce) as Sell0i from NC 
    where ND between @day0 and @day0+@period-1 and frizer=0 and Actn=0 and Tara=0
    group by B_ID;
  open CURSELL;
  fetch next from CURSELL into @b_id,@r,@sell0i;
  while @@FETCH_STATUS = 0 begin
    insert into #PLTMP(b_id,sell0,sell0i) values(@b_id,@r,@sell0i);
    fetch next from CURSELL into @b_id,@r,@sell0i;
  end;
  close CURSELL;
  deallocate CURSELL;
  
  -- Выплата и доход за самый ранний из трех периодов. Маленькая
  -- хитрость: если сумма исходной накладной строго 0, то прибыль равна оплате.
  /*
  declare CURPAY cursor for select 
    K.B_ID, sum(K.Plata) as Plata, 
    round(sum(case when nc.sp=0 then K.Plata else K.Plata*(nc.sp-nc.sc)/NC.sp END),2) as Dohod
    from Kassa1 K, NC 
    where (K.ND between @d00 and @d00+@period-1) and K.Oper=-2 and K.Act='ВЫ'
    and NC.Datnom=K.SourDatnom and NC.Frizer=0 and NC.Actn=0 and NC.Tara=0
    group by K.B_ID;
  open CURPAY;
  fetch next from CURPAY into @b_id,@Plata,@dohod;
  while @@FETCH_STATUS=0 begin
    insert into #PLTMP(B_ID, plata2, dohod2) values(@B_ID,@plata,@dohod);
    fetch next from CURPAY into @b_id,@Plata,@dohod;
  end;
  close CURPAY;
  deallocate CURPAY;
  */



  
  -- Выплата и доход за средний период
  declare CURPAY cursor for select 
    K.B_ID, sum(K.Plata) as Plata, 
    round(sum(case when nc.sp=0 then K.Plata else K.Plata*(nc.sp-nc.sc)/NC.sp END),2) as Dohod
    from Kassa1 K, NC 
    where (K.ND between @d01 and @d01+@period-1) and K.Oper=-2 and K.Act='ВЫ'
    and NC.Datnom=K.SourDatnom and NC.Frizer=0 and NC.Actn=0 and NC.Tara=0
    group by K.B_ID;
  open CURPAY;
  fetch next from CURPAY into @b_id,@Plata,@dohod;
  while @@FETCH_STATUS=0 begin
    insert into #PLTMP(B_ID, plata1, dohod1) values(@B_ID,@plata,@dohod);
    fetch next from CURPAY into @b_id,@Plata,@dohod;
  end;
  close CURPAY;
  deallocate CURPAY;

  
  -- За последний период считаем плату всего, плату отдельно за мороженое, 
  -- доход всего и отдельно доход от оплаты мороженого:    
  declare CURPAY cursor for select 
    K.B_ID, 
    sum(K.Plata) as Plata, 
    round(sum(case when nc.sp=0 then 0 else K.Plata*nc.SpIce/nc.SP END),2) as PlataIce,
    round(sum(case when nc.sp=0 then K.Plata else K.Plata*(nc.sp-nc.sc)/NC.sp END),2) as Dohod,
    round(sum(case when nc.sp=0 then 0 else K.Plata*(nc.spIce-nc.scIce)/NC.sp END),2) as DohodIce
    from Kassa1 K, NC 
    where (K.ND between @day0 and @day0+@period-1) and K.Oper=-2 and K.Act='ВЫ' 
    and NC.Datnom=K.SourDatnom and NC.Frizer=0 and NC.Actn=0 and NC.Tara=0
    group by K.B_ID;
    
  open CURPAY;
  fetch next from CURPAY into @b_id,@Plata,@plataIce,@dohod,@dohodIce;
  while @@FETCH_STATUS=0 begin
    insert into #PLTMP(B_ID, plata0, plata0i, dohod0,dohod0i,dohod0m) values(@B_ID,@plata,@plataIce,@dohod,@dohodIce,@dohod-@dohodIce);
    fetch next from CURPAY into @b_id,@Plata,@plataIce,@dohod,@dohodIce;
  end;
  close CURPAY;
  deallocate CURPAY;

  
select 
  p.b_id, d.gpname, d.tip,d.brname, 
  sum(p.plata0) plata0, sum(p.plata0i) plata0i,  sum(p.plata1) plata1,
  sum(p.plata2) plata2, 
  SUM(p.sell0) sell0, 
  SUM(p.sell0i) sell0i, 
  sum(p.sell1) sell1, sum(p.sell2) sell2,
  sum(p.dohod0) dohod0, sum(p.dohod1) dohod1, sum(p.dohod2) dohod2,
  sum(p.dohod0i) as dohod0i, sum(p.dohod0m) as dohod0m
from 
  #pltmp p left outer join def d on d.pin=p.b_id and d.tip=1
  group by p.b_id, d.gpname, d.tip,d.brname
  order by p.b_id
end