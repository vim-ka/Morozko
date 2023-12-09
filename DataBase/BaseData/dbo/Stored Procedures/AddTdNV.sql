/*
create table tdNV (nd datetime,
  Nnak INT,
  tekid int,
  price money, cost money, Kol decimal(12,3), Sklad tinyint, Kol_B decimal(12,3))
*/
CREATE procedure AddTdNV  @nd datetime, @Nnak INT, @tekid int,
  @price money, @cost money, @Kol decimal(12,3), @Sklad tinyint, @Kol_B decimal(12,3)
as
begin
  /*insert into tdNV(nd,nnak,tekid,price,cost,kol,sklad,kol_b)
  values(@nd,@nnak,@tekid,@price,@cost,@kol,@sklad,@kol_b)*/
  
  insert into NV (DatNom,TekID,Hitag,price,cost,kol,kol_b,sklad)
  values(dbo.InDatNom(@Nnak,@nd),@tekid,0,@price,@cost,@kol,@kol_b,@sklad)
end  


/*
select * from advorder a where a.DATE between '20090701' and '20090716' 

select a.pin, a.hitag, a.name, sum(a.qty) as qty
from advorder a where a.DATE between '20090701' and '20090716' 
group by a.pin, a.hitag, a.name
order by a.pin,a.name

select a.ag_id,ag.fam,a.pin,d.gpname,d.brname, sum(a.qty/nm.minp) as BoxQty 
from advorder a, nomen nm, agents ag, def d
where 
  a.DATE between '20090701' and '20090716' 
  and nm.hitag=a.hitag
  and ag.ag_id=a.ag_id
  and d.pin=a.pin and d.tip=1
group by a.ag_id,ag.fam, a.pin, d.gpname,d.brname
order by a.ag_id,a.pin 
*/