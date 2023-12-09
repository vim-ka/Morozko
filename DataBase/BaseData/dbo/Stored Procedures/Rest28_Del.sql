

CREATE procedure Rest28_Del 
as
begin
  create table #Back (hitag int, sklad int, id int, price decimal(10,2),back int
    primary key (id));
  insert into #Back select
    max(nv.hitag) hitag, max(nv.sklad) sklad, nv.TekID, max(nv.price), sum(-nv.kol) as back
    from nv inner join nc on nc.datnom=nv.datnom
    where nv.DatNom>=1007280001 and NC.SP<0 and nc.remark like 'возвр.%(%5)'
    group by nv.TekID;
  
  select 
    b.hitag, b.sklad, b.id, b.price, b.back, isnull(v.morn,0) as StartKol
  into #b2
  from #back b 
    left join vi28 v on v.id=b.id
  group by b.hitag, b.sklad, b.id, b.price, b.back, isnull(v.morn,0)  

 select b.hitag, b.sklad, b.id, b.price, b.back, b.startkol, sum(isnull(nv.kol,0)) as Sell
 into #b3
 from #b2 b
   left join nv on nv.tekid=b.id
   inner join nc on nc.datnom=nv.datnom
 where nc.nd>='20100728' --and nc.sc>0
 group by b.hitag, b.sklad, b.id, b.price, b.back, b.startkol
 
 update #b3 set Sell=Sell-back
  
 select b.hitag, b.sklad, b.id, b.price, b.back, b.startkol, b.Sell,
   sum(iz.kol-Izmen.newkol) as Remov
 into TempSvod   
 from #b3 b 
   inner join Izmen iz on iz.id=b.id and id.nd>='20100728' and iz.act='Снят'
 order by b.id 
  
end;