CREATE procedure LoadData.getRegisterBillChange 
@Our_ID int, 
@nd1 datetime, 
@nd2 datetime
as
begin
/*select x.datnom [vk], x.newsp [sum]
from (
select ce.datnom, ce.newsp, row_number() over(order by ce.ncid desc) [ord] 
from dbo.ncedit ce inner join dbo.nc n on ce.datnom=n.datnom 
where n.OurID=@Our_id and ce.nd between @nd1 and @nd2) x 
where [ord]=1 
order by 1*/
set nocount on
if object_id('tempdb..#src') is not null drop table #src
create table #src (datnom int)
create nonclustered index src_datnom_idx on #src(datnom)
if object_id('tempdb..#res') is not null drop table #res
create table #res (vk int, [sum] money)
create nonclustered index res_vk_idx on #res(vk)
insert into #src
select c.startdatnom
from dbo.nc c 
where c.ourid=@our_id and c.nd between @nd1 and @nd2 and c.startdatnom<>c.datnom
			and c.actn<>1 and c.frizer=0 and c.tara=0 and c.stip not in (2,3,4) and ((c.sp>0)or(c.sp<0 and c.remark=''))
group by c.startdatnom
union 
select x.dtn
from (
select n.startdatnom [dtn], row_number() over(partition by ce.datnom order by ce.ncid desc) [ord] 
from dbo.ncedit ce inner join dbo.nc n on ce.datnom=n.datnom 
where n.OurID=@Our_id and ce.nd between @nd1 and @nd2) x 
where [ord]=1
insert into #res
select c.startdatnom [vk], sum(c.sp) [sum]
from dbo.nc c
join #src on c.startdatnom=#src.datnom
where c.ourid=@our_id and c.nd<=@nd2 and c.actn<>1 and c.frizer=0 and c.tara=0 and c.stip not in (2,3,4)
			and ((c.sp>0)or(c.sp<0 and c.remark=''))
group by c.startdatnom
order by 1
delete r
from #res r join dbo.nc c on c.datnom =r.vk
where patindex('%Перебито%',c.fam)<>0 or patindex('%Перемещена%',c.fam)<>0
select * from #res
if object_id('tempdb..#src') is not null drop table #src
if object_id('tempdb..#res') is not null drop table #res
set nocount off
end