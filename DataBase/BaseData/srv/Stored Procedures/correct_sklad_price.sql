CREATE procedure srv.correct_sklad_price
as
begin
  set nocount on
  if object_id('tempdb..#base') is not null drop table #base
  create table #base (id int not null, base_id int not null, unit_price money not null, weight decimal(15,4) not null, is_weight bit not null,
                                        comman_unit_price money, in_comman bit, hitag int)
  create nonclustered index base_idx on #base(id)
  create nonclustered index base_idx1 on #base(base_id)
  insert into #base
  select v.id, v.startid, iif(n.flgweight=1,v.price/v.weight,v.price) [unit_price], v.weight, n.flgweight,
               iif(n.flgweight=1 and i.weight>0,i.price/i.weight,iif(n.flgweight=0,i.price,null)),cast(iif(i.id is null,0,1) as bit), v.hitag
  from dbo.tdvi v
  join dbo.nomen n on n.hitag=v.hitag
  join dbo.gr g on g.ngrp=n.ngrp
  join dbo.skladlist s on s.skladno=v.sklad
  left join dbo.inpdet i on i.id=v.startid 
  where (n.flgweight=1 and v.weight>0 or n.flgweight=0)
              and g.aginvis=0 
        and s.discard=0 and s.discount=0 and s.safecust=0 and s.equipment=0
        
  delete from #base where in_comman=1 and (abs(comman_unit_price-unit_price)<=0.1 or comman_unit_price<=0.01)    
  delete from #base where id in (select newid from dbo.izmen where act='ИзмЦ')

  select * from #base where in_comman=1
  select * from #base where in_comman=0

  if object_id('tempdb..#base') is not null drop table #base
  set nocount off
end