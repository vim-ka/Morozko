CREATE procedure dbo.PrepareDebetByDCK @day0 datetime, @day1 datetime, @OurIdList varchar(200)='0,1,2,3,4,5,6,7,8,90,11,12,13,14,15,16,17'
as 
begin
  -- список разрешенных кодов наших фирм:
  create table #O(our_id int);
  insert into #O select K from dbo.Str2intarray(@OurIdList);

  -- Таблица продаж покупателям:
  create table #r (DCK int, sp decimal(12,2))
  insert into #r
    select nc.dck, 
       sum(nc.sp) SP 
       from NC inner join #O on #o.our_id=nc.OurID
       where 
         nd between @day0 and @day1
         and nc.dck>0
         and nc.tara=0
         and nc.actn=0
         and nc.frizer=0
         and nc.sp>0
       group by nc.dck;
  create index r_idx_dck on #r(dck);
       
  -- Таблица возвратов от покупателей:
  create table #v (dck int, sp decimal(12,2))
  insert into #v
    select nc.dck, 
       sum(-nc.sp) SP 
       from NC  inner join #O on #o.our_id=nc.OurID
       where nd between @day0 and @day1
         and nc.dck>0
         and nc.tara=0
         and nc.actn=0
         and nc.frizer=0
         and nc.sp<0
       group by nc.dck;
  create index v_idx_dck on #v(dck);

  -- Таблица выплат покупателей:
  create table #p (dck int, pay decimal(12,2));
  insert into #p
    select dck, sum(plata) as Pay
    from Kassa1  inner join #O on #o.our_id=Kassa1.Our_ID
    where dck>0 and oper=-2 and nd between @day0 and @day1
    group by dck;
  create index p_idx_dck on #p(dck);
       
  select 
    dc.pin as B_ID,
    s.dck, def.gpName as GPol, def.LicNo, def.Srok, def.[Limit], 
    dc.ContrName,
    s.debt as Debt0,
    isnull(#R.SP,0) as Debet,
    isnull(#V.SP,0)+isnull(#p.Pay,0) as Credit,
    dc.Our_id, F.OurName
  from 
    DefContract DC 
    inner join #O on #o.our_id=dc.Our_id
    left join DailySaldoDck s on s.B_ID=DC.pin and s.dck=dc.dck and s.dck>0 and dc.contrtip=2 and s.nd=@day0-1
    inner join Def on Def.pin=dc.pin
    left join #R on #R.dck=dc.dck
    left join #V on #V.dck=dc.dck
    left join #P on #P.dck=dc.dck
    left join FirmsConfig F on F.Our_id=dc.Our_id
  where dc.dck>0 and s.dck>0 and def.tip in (1,10)
  order by dc.pin,s.dck;
end