CREATE procedure tax.get_contractlist 
@job_id int
as
begin
set nocount on
declare @pin int, @isSingle bit, @master int, @use_net bit
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

select dc.dck, dc.contrname, cast(d.pin as varchar)+':'+d.brname [list], isnull(sd.debt,0) [debt], dc.pin 
from dbo.defcontract dc
join dbo.def d on d.pin=dc.pin
join #pin on #pin.pin=dc.pin
left join dbo.dailysaldodck sd on sd.dck=dc.dck and sd.nd=dateadd(day,-1,dbo.today())
--where isnull(sd.debt,0)>0 or dc.pin=@pin 
order by [pin],[dck]

if object_id('tempdb..#pin') is not null drop table #pin
set nocount off
end