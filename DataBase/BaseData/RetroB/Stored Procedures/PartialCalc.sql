

CREATE procedure retrob.PartialCalc
  @day0 datetime, @day1 datetime, 
  @VedID int,  @RBID int
  with recompile
as
begin

  -- Какие именно накладные нас интересуют?
  create table #n (datnom int);  
  insert into #n
  select distinct r.datnom
  from 
    retrob.rb_rawdet d
    inner join retrob.rb_raw r on r.rawid=d.rawid
  where
    d.vedid=@vedid and d.rbid=@rbid;
  
  -- Дергаю все выплаты по указанному списку накладных:
  create table #k (datnom int, SP decimal(12,2), Pay decimal(12,2), NewPayKoeff decimal(17,10) default 1);
  insert into #k(datnom,sp,pay) 
  select k.sourdatnom, nc.sp, sum(k.Plata) as Pay
  from 
    kassa1 k -- было retrob.kassa1 k 
    inner join #n on #n.datnom=k.sourdatnom
    inner join nc on nc.datnom=k.sourdatnom
  where 
    k.oper=-2
    and ( (isnull(k.bank_id,0)=0 and k.nd between @day0 and @day1 )
         or (isnull(k.bank_id,0)<>0 and k.bankday between @day0 and @day1)  ) 
  group by k.sourdatnom, nc.sp;
  
  -- Что вышло?
  update #k set NewPayKoeff=Pay/Sp where SP<>0;
  -- select * from #k


  select
    d.VedId, r.b_id, def.gpname,  r.datnom, d.RawId, 
    r.hitag, nm.name, r.kol, r.price, #k.NewPayKoeff as PayKoeff, 
    r.kol*r.price*#k.NewPayKoeff as Base, d.Bonus*#k.NewPayKoeff as Bonus,
    r.Ncod, r.Ngrp 
  from
    retrob.rb_rawdet d
    inner join retrob.rb_raw r on r.rawid=d.rawid
    inner join retrob.rb_Buyers b on b.rbid=d.rbid 
       and ((b.netmode=0 and b.pin=r.b_id) or (b.netmode=1 and b.pin=r.master))
    inner join #k on #k.datnom=r.datnom
    left join Def on Def.pin=r.b_id
    left join Nomen nm on nm.hitag=r.hitag
  where
    d.vedid = @VedID
    and d.rbid=@rbid
  order by
    r.hitag, r.datnom  
end;