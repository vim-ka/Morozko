CREATE PROCEDURE ELoadMenager.eload_vendor_realiz_back_nomen
@nd1 datetime, 
@nd2 datetime,
@ncod varchar(2000) 
with recompile
as
begin
declare @nd datetime
set nocount on
if object_id('tempdb..#ncods') is not null drop table #ncods
if object_id('tempdb..#tmp_realiz') is not null drop table #tmp_realiz

create table #ncods([id] int)
if isnull(@ncod,'')=''
	insert into #ncods
	select ncod from dbo.vendors
else
	insert into #ncods
  select value from string_split(@ncod,',')
  
create nonclustered index ncods_idx1 on #ncods([id])

if object_id('tempdb..#agents_date') is not null drop table #agents_date
create table #agents_date (ag_id int, depid int, nd datetime, datnom int)
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

create nonclustered index ag_nd_idx1 on #agents_date([ag_id],[nd])

select c.nd [Дата],c.fam [НаименованиеКлиента],de.dname [Отдел],c.datnom, c.ag_id,
       --sum(v.kol) [kol],sum(s.weight*v.kol) [w],
       case when c.sp<0 and c.remark<>'' then 'возврат'
       		  when c.b_id in (7500,7501,7502,7503,7504) then 'списание'
            else 'реализация' end [тип], 
       --iif(c.sp<0 and c.remark<>'','возврат','реализация') [тип],
       n.name [Номенклатура],
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
group by c.nd,c.fam,de.dname,c.sp,c.remark,c.sp,c.b_id,c.remark,c.datnom,c.ag_id, n.name
    
if object_id('tempdb..#ncods') is not null drop table #ncods 
if object_id('tempdb..#tmp_realiz') is not null drop table #tmp_realiz 
if object_id('tempdb..#agents_date') is not null drop table #agents_date
set nocount off
end