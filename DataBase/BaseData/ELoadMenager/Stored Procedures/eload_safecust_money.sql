create procedure eLoadmenager.eload_safecust_money
@dck int, @nd1 datetime, @nd2 datetime
as
begin
set nocount on
declare @cost_safe_frost money =0.35, @cost_safe_nofrost money =0.25, @cost_process money =1, @cost_delivery money =3

select convert(varchar,v.workdate,104) [дата], cast(iif(m.min_term<0,1,0) as bit) [заморозка?], 
			 cast(sum(v.mornrest*iif(n.flgweight=1,v.weight,n.brutto)) as decimal(15,2)) [остаток_кг],
			 cast(sum(v.mornrest*iif(n.flgweight=1,v.weight,n.brutto)*iif(m.min_term<0,@cost_safe_frost,@cost_safe_nofrost)) as decimal(15,2)) [сумма_руб]
from morozarc.dbo.arcvi v
join dbo.nomen n on n.hitag=v.hitag
join dbo.gr g on g.ngrp=n.ngrp
join nearlogistic.masstype m on m.nlmt=g.nlmt_new
where v.dck=@dck and v.workdate between @nd1 and @nd2
group by v.workdate, cast(iif(m.min_term<0,1,0) as bit)
order by 1, 2 desc

select convert(varchar,c.nd,104) [дата], cast(iif(m.min_term<0,1,0) as bit) [заморозка?], 
			 c.b_id [код_клинета], c.fam [клиент], 
			 cast(sum(v.kol*iif(n.flgweight=1,s.weight,n.brutto)) as decimal(15,2)) [тоннаж_кг],
       cast(sum(@cost_process*v.kol*iif(n.flgweight=1,s.weight,n.brutto)) as decimal(15,2)) [сумма_руб]       
from dbo.nc c 
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.visual s on s.id=v.tekid
join dbo.nomen n on n.hitag=v.hitag
join dbo.gr g on g.ngrp=n.ngrp
join nearlogistic.masstype m on m.nlmt=g.nlmt_new
where c.gpour_id=@dck and c.nd between @nd1 and @nd2
group by c.nd, cast(iif(m.min_term<0,1,0) as bit), c.b_id, c.fam
order by 1, 2 desc

select convert(varchar,c.nd,104) [дата], cast(iif(m.min_term<0,1,0) as bit) [заморозка?], 
			 c.b_id [код_клиента], c.fam [клиент], c.marsh [маршрут],
			 cast(sum(v.kol*iif(n.flgweight=1,s.weight,n.brutto)) as decimal(15,2)) [тоннаж_кг],       
       cast(sum(@cost_delivery*v.kol*iif(n.flgweight=1,s.weight,n.brutto)) as decimal(15,2)) [сумма_руб]       
from dbo.nc c 
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.visual s on s.id=v.tekid
join dbo.nomen n on n.hitag=v.hitag
join dbo.gr g on g.ngrp=n.ngrp
join nearlogistic.masstype m on m.nlmt=g.nlmt_new
where c.gpour_id=@dck and c.nd between @nd1 and @nd2 and not c.marsh in (0,99) and c.marsh<200
group by c.nd, cast(iif(m.min_term<0,1,0) as bit), c.b_id, c.fam, c.marsh
order by 1, 2 desc
set nocount off
end