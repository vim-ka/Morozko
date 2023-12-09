CREATE procedure ELoadMenager.eload_backnomensklad
@nd datetime,
@hitags varchar(max) ='',
@sklads varchar(max) =''
--with recompile
as
begin
set nocount on
if object_id('tempdb..#htg') is not null drop table #htg
if object_id('tempdb..#skl') is not null drop table #skl

create table #htg (hitag int)
create nonclustered index htg_idx on #htg(hitag)
create table #skl (sklad int)
create nonclustered index skl_idx on #skl(sklad)

if isnull(@hitags,'')=''
insert into #htg select hitag from dbo.nomen 
else insert into #htg select value from string_split(@hitags,',')

if isnull(@sklads,'')=''
insert into #skl select skladno from dbo.skladlist 
else insert into #skl select value from string_split(@sklads,',')

select c.nd [дата], c.datnom%10000 [накладная], c.b_id [код_покупателя], c.fam [покупатель],
			 n.hitag [код_товара], n.name [наименование_товара], v.kol [количество_штук], v.kol*s.weight [количество_килограммы],
       --/*
       isnull(
       (select sum(z.kol)
       	from dbo.nc x 
        join dbo.nv z with(nolock, index(nv_datnom_idx)) on x.datnom=z.datnom 
        where z.hitag=v.hitag and x.startdatnom=c.startdatnom and x.nd=c.nd and x.sp>0
        ),0) [реализация_штуки],       
       isnull(
       (select sum(y.weight*z.kol)
       	from dbo.nc x
        join dbo.nv z with(nolock, index(nv_datnom_idx)) on x.datnom=z.datnom
        join dbo.visual y on y.id=z.tekid
        where z.hitag=v.hitag and x.startdatnom=c.startdatnom and x.nd=c.nd and x.sp>0
        ),0) [реализация_килограммы],
       --*/
       isnull(r.reason,isnull(rmr.reason,'нет причины')+', '+isnull(rm.remark,'нет комментария')) [причина]
from dbo.nc c 
join dbo.nv v with (nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.nomen n on n.hitag=v.hitag
join dbo.visual s on s.id=v.tekid 
left join dbo.reqreturndet d on d.reftekid=v.tekid
left join dbo.reasontortrn r on r.reason_id=d.ret_reason
left join dbo.remtortrn rm on rm.datnom=c.datnom and rm.hitag=v.hitag
left join dbo.reasontortrn rmr on rmr.reason_id=rm.reason_id
where c.nd>='20170601' and c.sp<0
			and v.hitag in (select hitag from #htg) 
      and v.sklad in (select sklad from #skl)
 
if object_id('tempdb..#htg') is not null drop table #htg
if object_id('tempdb..#skl') is not null drop table #skl
set nocount off
end