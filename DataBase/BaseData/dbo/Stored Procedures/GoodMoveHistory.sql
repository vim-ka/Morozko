CREATE PROCEDURE dbo.GoodMoveHistory
@id int
AS
BEGIN
create table #t(id int, rowid int identity(1,1))

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
end


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
        iif(i.newweight>0, i.NewPrice/i.newweight, 0) as newprice1kg,
        i.sklad, 
        i.newsklad,
        i.ncod
from izmen i
inner join #t t on t.id=i.id or t.id=i.newid
union all   
select  c.ncom,
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
        iif(d.weight>0, d.price/d.weight, 0) as pricet1kg,
        0 as newprice1kg,
        0 as sklad, 
        d.sklad as newsklad,
        c.ncod
from Inpdet d 
inner join comman c on c.Ncom=d.ncom
where d.id=(select min(id) from #t)

union all

select  c.datnom,
        c.nd,
        c.tm,
        'Возв',
        0,
        v.tekid,
        v.hitag,
        v.hitag,
        0,
        cast(v.kol as integer),
        0,
        i.weight,
        v.price,
        v.price,
        v.cost,
        v.cost,
        c.op,
        c.comp,
        0,
        '',
        iif(i.weight>0, i.cost/i.weight, 0) as cost1kg,
        0 as newcost1kg,
        iif(i.weight>0, i.price/i.weight, 0) as pricet1kg,
        0 as newprice1kg,
        0 as sklad,
        v.sklad as newsklad,
        i.ncod
from nv v join nc c on v.datnom=c.datnom
          join visual i on v.tekid=i.id
          join #t on v.tekid=#t.id
where v.kol<0

) x
drop table #t

select distinct
			 r.*,
       u.fio 
from #res r
left join usrpwd u on u.uin=r.op
order by r.ND, r.tm, r.izmID

drop table #res
END