CREATE procedure PrepareDebet @day0 datetime, @day1 datetime
as 
begin
  -- Таблица продаж:
  create table #r (b_id int, sp decimal(12,2))
  insert into #r
    select nc.b_id, 
       sum(nc.sp) SP 
       from NC 
       where nd between @day0 and @day1
         and nc.tara=0
         and nc.actn=0
         and nc.frizer=0
         and nc.sp>0
       group by nc.B_ID;
  create index r_idx_bid on #r(b_id);
       
  -- Таблица возвратов:
  create table #v (b_id int, sp decimal(12,2))
  insert into #v
    select nc.b_id, 
       sum(-nc.sp) SP 
       from NC 
       where nd between @day0 and @day1
         and nc.tara=0
         and nc.actn=0
         and nc.frizer=0
         and nc.sp<0
       group by nc.B_ID;
  create index v_idx_bid on #v(b_id);

  -- Таблица выплат:
  create table #p (b_id int, pay decimal(12,2));
  insert into #p
    select b_id, sum(plata) as Pay
    from Kassa1
    where oper=-2 and nd between @day0 and @day1
    group by b_id;
  create index p_idx_bid on #p(b_id);
       
  select 
    s.b_id, def.gpName as GPol, def.LicNo, def.Srok, def.[Limit], s.debt as Debt0,
    isnull(#R.SP,0) as Debet,
    isnull(#V.SP,0)+isnull(#p.Pay,0) as Credit
  from 
    Def left join DailySaldoBR s on s.B_ID=def.pin and s.nd=@day0-1
    left join #R on #R.b_id=def.pin
    left join #V on #V.b_id=def.pin
    left join #P on #P.b_id=def.pin
  where def.tip=1
  order by s.b_id;
end