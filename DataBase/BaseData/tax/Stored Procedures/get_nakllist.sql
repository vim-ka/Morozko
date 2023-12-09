CREATE procedure tax.get_nakllist
@job_id int,
@dt1 datetime,
@dt2 datetime
as
begin
set nocount on
declare @pin int, @master int, @isSingle bit, @dcklist varchar(100), @use_net bit
if object_id('tempdb..#pin') is not null drop table #pin
create table #pin(pin int not null default 0)
create nonclustered index pin_idx on #pin(pin)

select @pin=j.pin, @isSingle=j.isSingle, @master=d.master
from tax.job j
join dbo.def d on d.pin=j.pin
where j.job_id=@job_id

set @use_net=cast(iif(@isSingle=0 and @master>0,1,0) as bit)

if @use_net=1
begin
	insert into #pin
  select distinct d.pin
  from dbo.def d 
  where d.master=@master
  
  delete from #pin 
  where pin in (select pin from tax.job where issingle=1 and closed=0)
end
else insert into #pin values(@pin)

select c.datnom%10000 [datnumber],c.ourid,c.extra,c.nd,c.datnom [id],c.ck,
       c.sp,c.srok,isnull(c.back,0) [back],
       case when c.actn=0 then isnull(c.fact,0)
       			else isnull(c.fact,0)+isnull(c.sp,0) end [fact],
       isnull(k.plata,0) [plata],df.gpName +' '+dc.ContrName [gpname],
       case when isnull(c.actn,0)=0 then (isnull(c.sp,0)+isnull(c.izmen,0)-isnull(c.fact,0)) else 0 end [duty],
       isnull(c.izmen ,0) [izmen],c.b_id,c.datnom,dc.ag_id [brag_id],isnull(c.actn,0) [actn],
       c.nd+c.srok+3 [dsrok],c.fam,c.nd+c.srok+1 [prsrok],c.dck
from dbo.nc c 
join dbo.defcontract dc on dc.dck=c.dck
join (select distinct pin from #pin) x on x.pin=dc.pin
join dbo.def df on dc.pin=df.pin
left join (select a.sourdatnom,sum(a.plata) [plata], a.dck 
					 from dbo.kassa1 a where a.nd=dbo.today() group by a.sourdatnom, a.dck) k on c.dck=k.dck and c.datnom=k.sourdatnom
where c.tara=0 and c.frizer=0
			and c.nd between @dt1 and @dt2       
order by c.nd desc, datnumber desc

if object_id('tempdb..#pin') is not null drop table #pin
set nocount off
end