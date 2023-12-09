CREATE procedure ELoadMenager.eload_sklad_load_work
@nd1 datetime ='20180409', @nd2 datetime ='20180415', @all bit=0, @weight_limit decimal(15,2) =1
as
begin
set nocount on
declare @dn1 int =dbo.indatnom(0,@nd1), @dn2 int =dbo.indatnom(9999,@nd2)
if object_id('tempdb..#base') is not null drop table #base

select distinct cast('база' as nvarchar(15)) [tip], 0 [ord], c.datnom, c.startdatnom, c.nd, v.sklad, n.flgweight, v.hitag, n.name, 
			 iif(n.flgweight=1,isnull(z.zakaz,v.kol)*n.netto,isnull(z.zakaz,v.kol)) [zakaz], v.tekid [id], cast(v.kol as decimal(17,4)) [qty], cast('' as nvarchar(500)) [reason], cast(isnull(z.remark,'') as nvarchar(500)) [remark]
into #base
from dbo.nc c 
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.nomen n on n.hitag=v.hitag
left join dbo.nvzakaz z on v.tekid=z.id and c.datnom=z.datnom
where c.datnom between @dn1 and @dn2 and c.datnom=c.startdatnom
			and (c.sp>0 or (c.sp=0 and c.actn=1))

insert into #base
select distinct cast('добивка' as nvarchar(15)) [tip], 1 [ord], c.datnom, c.startdatnom, c.nd, v.sklad, n.flgweight, v.hitag, n.name, 
			 iif(n.flgweight=1,isnull(z.zakaz,v.kol)*n.netto,isnull(z.zakaz,v.kol)) [zakaz], v.tekid, v.kol, cast('' as nvarchar(500)) [reason], cast(isnull(z.remark,'') as nvarchar(500)) [remark]
from dbo.nc c 
join #base on #base.datnom=c.startdatnom
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.nomen n on n.hitag=v.hitag
left join dbo.nvzakaz z on v.tekid=z.id and c.datnom=z.datnom
where c.datnom>=@dn1 and c.datnom<>c.startdatnom and c.sp>0

insert into #base
select distinct cast('отмена набора' as nvarchar(15)) [tip], 2 [ord], c.datnom, c.startdatnom, c.nd, z.skladno, n.flgweight, z.hitag, n.name, 
			 iif(n.flgweight=1,z.zakaz*n.netto,z.zakaz) [zakaz], 0, 0, cast('' as nvarchar(500)) [reason], cast(isnull(z.remark,'') as nvarchar(500)) [remark]
from dbo.nc c 
join #base on #base.datnom=c.startdatnom
join dbo.nvzakaz z on z.datnom=c.datnom
join dbo.nomen n on n.hitag=z.hitag
where c.datnom>=@dn1 and z.id=0 and z.done=1 and z.zakaz>0

insert into #base
select distinct cast('вычерк' as nvarchar(15)) [tip], 3 [ord], c.datnom, c.startdatnom, c.nd, v.sklad, n.flgweight, v.hitag, n.name, 
			 v.kol*iif(n.flgweight=1,n.netto,1) [zakaz], v.tekid, v.kol, isnull(rs.reason,'') [reason], isnull(rr.remark,'') [remark]
from dbo.nc c 
join #base on #base.datnom=c.refdatnom and c.remark=''
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.nomen n on n.hitag=v.hitag
left join dbo.remtortrn rr on c.datnom=rr.datnom
left join dbo.reasontortrn rs on rr.reason_id=rs.reason_id
where c.datnom>=@dn1 and c.sp<0

insert into #base
select distinct cast('возврат' as nvarchar(15)) [tip], 4 [ord], c.datnom, c.startdatnom, c.nd, v.sklad, n.flgweight, v.hitag, n.name, 
			 v.kol*iif(n.flgweight=1,n.netto,1) [zakaz], v.tekid, v.kol, isnull(rs.reason,'') [reason], isnull(rr.remark,'') [remark]
from dbo.nc c 
join #base on #base.datnom=c.refdatnom and c.remark<>''
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.nomen n on n.hitag=v.hitag
left join dbo.remtortrn rr on c.datnom=rr.datnom
left join dbo.reasontortrn rs on rr.reason_id=rs.reason_id
where c.datnom>=@dn1 and c.sp<0

update b set b.qty=s.weight*b.qty
from #base b
join dbo.visual s on s.id=b.id
where b.flgweight=1 and b.id>0

select dbo.datnomindate(z.startdatnom) [дата], z.nnak [накладная], z.sklad [склад], z.flgweight [весовой], z.hitag [код_товара], z.name [наименование],
			 cast(z.zakaz as decimal(15,2)) [заказ], cast(z.[add] as decimal(15,2)) [добивка], cast(z.cancel as decimal(15,2)) [отмена_набора], 
       cast(z.[dec] as decimal(15,2)) [вычерк], cast(z.ret as decimal(15,2)) [возврат], cast(z.qty_client as decimal(15,2)) [клиент],
       z.cancel_remark [отмена_набора_комментариц], z.dec_remark [вычерк_комментарий], z.dec_reason [вычерк_причина], z.ret_remark [возврат_комментарий], z.ret_reason [возврат_причина]			
from (
  select x.*, a.zakaz, b.qty [add], c.zakaz [cancel], c.remark [cancel_remark],
         d.qty [dec], d.remark [dec_remark], d.reason [dec_reason], e.qty [ret], e.remark [ret_remark], e.reason [ret_reason]       
  from (
    select startdatnom%10000 [nnak], sklad, hitag, flgweight, name, startdatnom, sum(iif(ord=4,0,qty)) [qty_client]
    from #base
    group by startdatnom%10000, sklad, hitag, flgweight, name, startdatnom) x
  left join (select a.startdatnom, a.hitag, sum(a.zakaz) [zakaz] from #base a where a.ord=0 group by a.startdatnom, a.hitag) a on x.startdatnom=a.startdatnom and x.hitag=a.hitag
  left join (select a.startdatnom, a.hitag, sum(a.qty) [qty] from #base a where a.ord=1 group by a.startdatnom, a.hitag) b on x.startdatnom=b.startdatnom and x.hitag=b.hitag
  left join (select a.startdatnom, a.hitag, sum(a.zakaz) [zakaz], a.remark from #base a where a.ord=2 group by a.startdatnom, a.hitag, a.remark) c on x.startdatnom=c.startdatnom and x.hitag=c.hitag
  left join (select a.startdatnom, a.hitag, sum(a.qty) [qty], a.remark, a.reason from #base a where a.ord=3 group by a.startdatnom, a.hitag, a.remark, a.reason) d on x.startdatnom=d.startdatnom and x.hitag=d.hitag
  left join (select a.startdatnom, a.hitag, sum(a.qty) [qty], a.remark, a.reason from #base a where a.ord=4 group by a.startdatnom, a.hitag, a.remark, a.reason) e on x.startdatnom=e.startdatnom and x.hitag=e.hitag) z
where abs(z.zakaz-z.qty_client)>iif(z.flgweight=1,@weight_limit,0) and (z.dec is not null or z.cancel is not null) or @all=1
order by 1, z.nnak, z.name

if object_id('tempdb..#base') is not null drop table #base
set nocount off
end