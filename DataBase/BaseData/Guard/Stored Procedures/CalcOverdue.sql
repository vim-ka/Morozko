

CREATE procedure guard.CalcOverdue @ND datetime
as
begin
  -- Список выплат:
  create table #p(datnom int, plata decimal(10,2));
  insert into #p
    select k.sourdatnom, sum(k.plata) from kassa1 k
    where iif(k.Bank_ID=0,k.nd, k.BankDay)<=@ND 
    and k.oper=-2 and k.Act in ('ВЫ','ВО')
      group by k.sourdatnom;
  create index p_tmp_idx on #p(datnom);    

  -- Список изменений:
  create table #z (datnom int, delta decimal(10,2));
  insert into #z select datnom, sum(izmen) from NcIzmen where nd<=@ND group by datnom;
  create index z_tmp_idx on #z(datnom);    

  -- Промежуточный результат:
  create table #r (Deep int, Debt decimal(12,2));
  insert into #r
  SELECT 
    DATEDIFF(day,dateadd(day, nc.srok, nc.nd), @ND) as Deep,
    sum(nc.sp-isnull(#p.plata,0)+ISNULL(#Z.delta,0)) as Debt
  from 
    nc
    left join #p on #p.datnom=nc.datnom
    left join #z on #z.datnom=nc.datnom 
  where 
    nc.srok>0 and nc.frizer=0 and nc.Actn=0
    and DATEDIFF(day,dateadd(day, nc.srok, nc.nd), @ND)>0
  group by 
    DATEDIFF(day,dateadd(day, nc.srok, nc.nd), @ND)
  order by DATEDIFF(day,dateadd(day, nc.srok, nc.nd), @ND);  


  create table #s(sid int not null identity(1,1) primary key, hdr varchar(20), ovr decimal(12,2));

  insert into #s(hdr) VALUES('1-30');
  insert into #s(hdr) VALUES('31-50');
  insert into #s(hdr) VALUES('51-100');
  insert into #s(hdr) VALUES('101-150');
  insert into #s(hdr) VALUES('150 и более');

  update #s set ovr=(select sum(debt) from #r where deep between 1 and 30) where sid=1;
  update #s set ovr=(select sum(debt) from #r where deep between 31 and 50) where sid=2;
  update #s set ovr=(select sum(debt) from #r where deep between 51 and 100) where sid=3;
  update #s set ovr=(select sum(debt) from #r where deep between 101 and 150) where sid=4;
  update #s set ovr=(select sum(debt) from #r where deep>150) where sid=5;

  select * from #s order by sid;
  
end;