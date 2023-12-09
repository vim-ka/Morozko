CREATE procedure ELoadMenager.eload_vendor_realiz_back
@nd1 datetime, 
@nd2 datetime,
@ncod varchar(2000) 
with recompile
as
begin
set nocount on

if object_id('tempdb..#ncods') is not null drop table #ncods
if object_id('tempdb..#tmp_realiz') is not null drop table #tmp_realiz
if object_id('tempdb..#agents_date') is not null drop table #agents_date

declare @nd datetime

create table #ncods([id] int)
if isnull(@ncod,'')=''
	insert into #ncods
	select ncod from dbo.vendors
else
	insert into #ncods
  select value from string_split(@ncod,',')
  
create nonclustered index ncods_idx1 on #ncods([id])

create table #agents_date (ag_id int, depid int, nd datetime, datnom int)
create nonclustered index ag_nd_idx1 on #agents_date([ag_id],[nd])

set @nd=@nd1
while @nd<=@nd2
begin
	insert #agents_date 
  select distinct
  			 isnull(x.ag_id,a.ag_id), isnull(x.depid,a.depid), c.nd, c.datnom
  from dbo.nc c
  left join dbo.defcontract dc on dc.dck=c.dck
  left join dbo.agentlist a on a.ag_id=dc.ag_id
  left join (select ag_id,depid,min(h.ndclose) nd 
  					 from dbo.AgentListHistory h 
  					 where h.ndclose>@nd 
  					 group by ag_id,depid) x on x.ag_id=c.ag_id
  where c.nd=@nd  

	set @nd=dateadd(day,1,@nd)
end

create table #tmp_realiz (startid int, ncod int, fam varchar(500), flgweight bit, dname varchar(100), [kol] int,
												  w decimal(15,2), [тип] varchar(25), [сумма_продажной_закупки] decimal(15,2), [сумма_продажи] decimal(15,2),
                          [тоннаж] decimal(15,2))
create nonclustered index tmp_realiz_idx1 on #tmp_realiz(startid)

insert into #tmp_realiz
select s.startid,s.ncod,e.fam,n.flgweight,de.dname,
       sum(v.kol) [kol],sum(iif(n.flgweight=1,s.weight,n.netto)*v.kol) [w],
       case when c.sp<0 and c.remark<>'' then 'возврат'
       		  when c.b_id in (7500,7501,7502,7503,7504) then 'списание'
            else 'реализация' end [тип], 
       cast(sum(v.cost*v.kol) as decimal(15,2)) [сумма_продажной_закупки],
       cast(sum(v.price*v.kol*(1+(c.extra/100))) as decimal(15,2)) [сумма_продажи],
       sum(iif(n.flgweight=1,s.weight,n.netto)*v.kol) [тоннаж]
from dbo.nc c
join dbo.nv v with (nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.visual s on v.tekid=s.id
join dbo.nomen n on n.hitag=v.hitag
join #ncods on #ncods.[id]=s.ncod
join dbo.vendors e on e.ncod=s.ncod
left join #agents_date h on h.datnom=c.datnom
left join dbo.deps de on de.depid=h.depid
where c.nd between @nd1 and @nd2 and c.stip<>4 and c.tomorrow=0
group by c.sp,c.remark,s.startid,s.ncod,e.fam,n.flgweight,de.dname,c.b_id

select x.ncod [код_поставщика],
			 x.fam [наименование_поставщика],
			 x.[тип],
       x.dname [отдел],
       cast(sum(iif(i.id is null,x.[сумма_продажной_закупки],
                    iif(x.flgweight=1,(i.cost/iif(i.weight<>0,i.weight,1)*i.kol)*x.[w],i.cost*x.[kol]))) as decimal(15,2)) [сумма_первичной_закупки],
       sum(x.[сумма_продажной_закупки]) [сумма_продажной_закупки],
       sum(x.[сумма_продажи]) [сумма_продажи],
       sum(x.[тоннаж]) [тоннаж]
from #tmp_realiz x
left join dbo.inpdet i on i.id=x.startid
left join dbo.comman m on m.ncom=i.ncom
group by x.ncod, x.fam, x.[тип],x.dname
union all
select x.ncod, 
			 x.fam,
       'возврат поставщику',
       null,
       sum(iif(x.flgweight=1,x.cost,x.cost*x.kol)) [cost],
			 0,
       sum(iif(x.flgweight=1,x.price,x.price*x.kol)) [price], 
       sum(x.weight) [weight]
from (
select i.ncod,
			 v.fam,
       i.kol-i.newkol [kol],
       iif(n.flgWeight=1,i.weight-i.newweight,n.netto*(i.kol-i.newkol)) [weight],
       i.cost,
       i.price,
       n.flgWeight
from dbo.izmen i
join dbo.nomen n on n.hitag=i.hitag
join #ncods on #ncods.[id]=i.ncod
join dbo.vendors v on v.ncod=i.ncod
where i.act='снят' and i.serviceflag=0
      and i.nd between @nd1 and @nd2) x
group by x.ncod,x.fam   

order by 1, 3 desc, 4

--/*
select c.nd [Дата],c.fam [НаименованиеКлиента],de.dname [Отдел],c.datnom, c.ag_id,
       --sum(v.kol) [kol],sum(s.weight*v.kol) [w],
       case when c.sp<0 and c.remark<>'' then 'возврат'
       		  when c.b_id in (7500,7501,7502,7503,7504) then 'списание'
            else 'реализация' end [тип], 
       --iif(c.sp<0 and c.remark<>'','возврат','реализация') [тип],
       cast(sum(v.cost*v.kol) as decimal(15,2)) [сумма_продажной_закупки],
       cast(sum(v.price*v.kol*(1+(c.extra/100))) as decimal(15,2)) [сумма_продажи],
       sum(iif(n.flgweight=1,s.weight,n.netto)*v.kol) [тоннаж]
from dbo.nc c
join dbo.nv v with (nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.visual s on v.tekid=s.id
join dbo.nomen n on n.hitag=v.hitag
join #ncods on #ncods.[id]=s.ncod
join dbo.vendors e on e.ncod=s.ncod
left join #agents_date h on h.datnom=c.datnom--h.ag_id=c.ag_id and h.nd=c.nd
left join dbo.deps de on de.depid=h.depid
where c.nd between @nd1 and @nd2 and c.stip<>4 and c.tomorrow=0
group by c.nd,c.fam,de.dname,c.sp,c.remark,c.sp,c.b_id,c.remark,c.datnom,c.ag_id
--*/


select x.ncod [код_поставщика],
			 x.fam [наименование_поставщика],
			 x.[тип],
       --x.dname [отдел],
       i.hitag [КодТовара],
       n.name [Наименование],
       cast(sum(iif(i.id is null,x.[сумма_продажной_закупки],
                    iif(x.flgweight=1,(i.cost/iif(i.weight<>0,i.weight,1)*i.kol)*x.[w],i.cost*x.[kol]))) as decimal(15,2)) [сумма_первичной_закупки],
       sum(x.[сумма_продажной_закупки]) [сумма_продажной_закупки],
       sum(x.[сумма_продажи]) [сумма_продажи],
       sum(x.[тоннаж]) [тоннаж]
from #tmp_realiz x
left join dbo.inpdet i on i.id=x.startid
left join dbo.comman m on m.ncom=i.ncom
join dbo.nomen n on n.hitag=i.hitag
group by x.ncod, x.fam, x.[тип],/*x.dname*/i.hitag,n.name
union all
select x.ncod, 
			 x.fam,
       'возврат поставщику',
       --null,
       x.hitag,
       x.name,
       sum(iif(x.flgweight=1,x.cost,x.cost*x.kol)) [cost],
			 0,
       sum(iif(x.flgweight=1,x.price,x.price*x.kol)) [price], 
       sum(x.weight) [weight]
from (
select i.ncod,
			 v.fam,
       i.kol-i.newkol [kol],
       iif(n.flgWeight=1,i.weight-i.newweight,n.netto*(i.kol-i.newkol)) [weight],
       i.cost,
       i.price,
       n.flgWeight,
       n.hitag,
       n.name
from dbo.izmen i
join dbo.nomen n on n.hitag=i.hitag
join #ncods on #ncods.[id]=i.ncod
join dbo.vendors v on v.ncod=i.ncod
where i.act='снят' and i.serviceflag=0
      and i.nd between @nd1 and @nd2) x
group by x.ncod,x.fam,x.hitag,x.name  
    
if object_id('tempdb..#ncods') is not null drop table #ncods 
if object_id('tempdb..#tmp_realiz') is not null drop table #tmp_realiz 
if object_id('tempdb..#agents_date') is not null drop table #agents_date
set nocount off
end