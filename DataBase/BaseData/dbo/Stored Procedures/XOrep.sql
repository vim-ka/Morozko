CREATE procedure XOrep @n0 int, @n1 INT
as 
begin
  create table #sell (Period char(6), B_ID int, 
   w342 decimal(10,3), w448 decimal(10,3), w773 decimal(10,3), w285 decimal(10,3),
   w160 decimal(10,3), wOther decimal(10,3));
    
insert into #sell    
select
  convert(char(6),nc.nd,112) as Period, nc.B_ID, 
  SUM(case when v.ncod=342 then nv.Kol*nm.Netto else 0.0 end) as Weight342,
  SUM(case when v.ncod in (448,449,540) then nv.Kol*nm.Netto else 0.0 end) as Weight448,
  SUM(case when v.ncod=773 then nv.Kol*nm.Netto else 0.0 end) as Weight773,
  SUM(case when v.ncod in (285,346,572) then nv.Kol*nm.Netto else 0.0 end) as Weight285,
  SUM(case when v.ncod=160 then nv.Kol*nm.Netto else 0.0 end) as Weight160,
  SUM(case when v.ncod in (342,448,449,540,443,285,346,572,160) then 0 else nv.Kol*nm.Netto end) as WeightOther
from 
  NV inner join NC on NC.Datnom=NV.Datnom
  inner join Visual V on V.ID=Nv.tekid
  inner join Def b on b.pin=nc.b_id and b.tip in (1,10)
  inner join Nomen nm on nm.hitag=nv.hitag
  inner join Gr on GR.Ngrp=Nm.Ngrp
where 
  nv.datnom between @n0 and @n1
  and Gr.category=2
group by   
  convert(char(6),nc.nd,112), nc.B_ID
having
  SUM(case when v.ncod=342 then nv.Kol*nm.Netto else 0.0 end)<>0
  or SUM(case when v.ncod in (448,449,540) then nv.Kol*nm.Netto else 0.0 end)<>0
  or SUM(case when v.ncod=773 then nv.Kol*nm.Netto else 0.0 end)<>0
  or SUM(case when v.ncod in (285,346,572) then nv.Kol*nm.Netto else 0.0 end)<>0
  or SUM(case when v.ncod=160 then nv.Kol*nm.Netto else 0.0 end)<>0
  or SUM(case when v.ncod in (342,448,449,540,443,285,346,572,160) then nv.Kol*nm.Netto else 0.0 end)<>0
order by 
  convert(char(6),nc.nd,112),
  nc.B_ID
  select * from #sell order by period, B_ID;
end;