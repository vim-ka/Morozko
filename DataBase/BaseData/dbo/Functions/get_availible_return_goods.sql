CREATE function dbo.get_availible_return_goods (@nd datetime, @dck int, @hitag int)
returns @res table([sklad] int, [hitag] int, [flgweight] bit, [qty] int, [weight] decimal(15,2))
as
begin
insert into @res
select min(v.sklad) [sklad], n.hitag, n.flgweight,
       iif(n.flgweight=1,1,sum(v.kol-v.kol_b)) [qty], sum(abs(v.kol)*s.weight-isnull(j.weight_b,0)) [weight]       
from dbo.nc c 
join dbo.nv v  with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.nomen n on n.hitag=v.hitag
join dbo.visual s on s.id=v.tekid
left join (select nj.refdatnom, nj.reftekid, sum(nj.weight) [weight_b] from dbo.nv_join nj group by nj.refdatnom, nj.reftekid) j
          on v.datnom=j.refdatnom and v.tekid=j.reftekid               
where c.dck=@dck and v.hitag=iif(isnull(@hitag,0)=0,v.hitag,@hitag) and v.kol-v.kol_b>0 and c.actn=0 and datediff(day,c.nd,@nd)<=iif(n.ngrp=85,120,200)
group by n.hitag, n.flgweight
having (sum(v.kol-v.kol_b)>0 and n.flgweight=0) or (sum(abs(v.kol)*s.weight-isnull(j.weight_b,0))>0 and n.flgweight=1)

update r set r.qty=iif(r.flgweight=0,r.qty-b.qty,r.qty),
					   r.weight=iif(r.flgweight=0,r.weight,r.weight-b.weight)
from @res r
join (
	select n.hitag, 
         iif(n.flgweight=0,0,sum(iif(d.fact_weight2=0,d.fact_weight,d.fact_weight2))) [weight],
         iif(n.flgweight=0,sum(iif(d.fact_kol2=0,d.kol,d.fact_kol2)),1) [qty]
  from dbo.requests q
  join dbo.reqreturn r on r.reqnum=q.rk
  join dbo.reqreturndet d on d.reqretid=r.reqnum
  join dbo.nomen n on n.hitag=d.hitag
  where not q.rs in (6,7) and r.dck=@dck and d.hitag=iif(@hitag=0,d.hitag,@hitag)
  group by n.hitag, n.flgweight
) b on b.hitag=r.hitag

delete from @res where (qty<=0 and flgweight=0)or(weight<=0 and flgweight=1)
return
end