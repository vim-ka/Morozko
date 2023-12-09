CREATE procedure tax.get_turnsheet 
@job_id int,
@dt1 datetime,
@dt2 datetime,
@dck nvarchar(500) =''
as
begin
set nocount on
declare @pin int, @master int, @isSingle bit, @dcklist varchar(100), @use_net bit
if object_id('tempdb..#pin') is not null drop table #pin
create table #pin(pin int not null default 0)
create nonclustered index pin_idx on #pin(pin)
if object_id('tempdb..#dck') is not null drop table #dck
create table #dck(dck int not null default 0)
create nonclustered index dck_idx on #dck(dck)

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

select @dcklist=stuff((
select N''+cast(dc.dck as varchar)+','
from dbo.defcontract dc
join #pin on #pin.pin=dc.pin
join string_split(@dck,',') s on s.value=dc.dck or @dck=''
group by dc.dck
for xml path(''), type).value('.','varchar(max)'),1,0,'')

/*
select @dcklist=stuff((
select N''+cast(dc.dck as varchar)+','
from dbo.defcontract dc
join #pin on #pin.pin=dc.pin
group by dc.dck
for xml path(''), type).value('.','varchar(max)'),1,0,'')
*/

set @pin=iif(@use_net=1,@master,@pin)
set @use_net=iif(@dcklist='',@use_net,0)
exec dbo.calcbuyturnsheet_new @pin,@use_net,@dcklist,@dt1,@dt2
--select @pin [pin],@use_net [use_net],@dcklist [dcklist], @dt1 [dt1], @dt2 [dt2]

if object_id('tempdb..#pin') is not null drop table #pin
if object_id('tempdb..#dck') is not null drop table #dck
set nocount off
end