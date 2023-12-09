CREATE PROCEDURE dbo.[GoodMoveHistoryHitag]
@Hitag int, @ND1 datetime, @ND2 datetime
AS
BEGIN
/*create table #t(id int, rowid int identity(1,1))

insert into #t(id) values(@id)
create nonclustered index idx_tID on #t(id)

while exists(	select 1 
              from izmen 
              where newid in (select id from #t)
                    and not exists(select 1 from #t where #t.id=izmen.id)
                    and id<>0
              group by id)
begin
	insert into #t(id)
  select id 
  from izmen 
  where newid in (select id from #t)
  			and not exists(select 1 from #t where #t.id=izmen.id) 
        and id<>0
  group by id
end*/

  select * into #res from (
  select  i.izmID,
        i.ND,
        i.tm,
        i.act,
        i.id,
        i.newid,
        i.hitag,
        i.newhitag,
        i.kol,
        i.newkol,
        i.weight,
        i.NewWeight,
        i.price,
        i.newprice,
        i.cost,
        i.newcost,
        i.op,
        i.comp, 
        i.SerialNom,
        i.remark,
        iif(i.weight>0, i.cost/i.weight, 0) as cost1kg,
        iif(i.newweight>0, i.newcost/i.newweight, 0) as newcost1kg,
        iif(i.weight>0, i.price/i.weight, 0) as price1kg,
        iif(i.newweight>0, i.newprice/i.newweight, 0) as newprice1kg,
        i.sklad, i.newsklad 
from izmen i where i.ND>=@ND1 and i.ND<=@ND2 and (i.hitag=@hitag or i.newhitag=@hitag)

union all   
select  0,
        c.date,
        c.Time,
        'Прих',
        0,
        d.id,
        d.hitag,
        d.hitag,
        0,
        d.kol,
        0,
        d.weight,
        d.price,
        d.price,
        d.cost,
        d.cost,
        d.op,
        c.comp,
        0,
        '',
        iif(d.weight>0, d.cost/d.weight, 0) as cost1kg,
        0 as newcost1kg,
        iif(d.weight>0, d.price/d.weight, 0) as price1kg,
        0 as newprice1kg,        
        0 as sklad, d.sklad as newsklad
from Inpdet d 
inner join comman c on c.Ncom=d.ncom
where c.Date>=@ND1 and c.Date<=@ND2 and d.hitag=@hitag

union all
select  0,
        c.ND,
        c.Tm,
        'Прод',
        0,
        v.tekid,
        v.hitag,
        v.hitag,
        v.kol,
        0,
        u.weight,
        0,
        v.price,
        v.price,
        v.cost,
        v.cost,
        c.op,
        c.comp,
        0,
        '',
        iif(u.weight>0, v.cost/u.weight, 0) as cost1kg,
        0 as newcost1kg,
        iif(u.weight>0, v.price/u.weight, 0) as price1kg,
        0 as newprice1kg,        
        0 as sklad,
        v.sklad as newsklad
from nv v 
inner join nc c on c.datnom=v.datnom
inner join visual u on v.tekid=u.id
where c.ND>=@ND1 and c.ND<=@ND2 and v.hitag=@hitag
) x

--drop table #t

  select 
     r.nd,
     sum((newweight*newkol-weight*kol)) 
  from #res r
  left join usrpwd u on u.uin=r.op
  group by nd
  order by  nd -- r.izmID
  
  select r.*,u.fio
  from #res r
  left join usrpwd u on u.uin=r.op
  order by  nd

  drop table #res
END