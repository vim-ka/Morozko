CREATE procedure NearLogistic.checkmarshbeforeprint
@mhID int,
@nd datetime=null,
@marsh int=0
AS
begin
set nocount off
if isnull(@mhid,0)=0 select @mhid=mhid from dbo.marsh where nd=@nd and marsh=@marsh

if object_id('tempdb..#req') is not null drop table #req

declare @res bit
declare @msg varchar(5000)

set @res=0
set @msg=''

create table #req ([id] int, [pin] int, [msg] varchar(2000))
--тащим все заявки на развоз по маршруту 
insert into #req
select c.datnom [id],
    c.b_id,
    '№'+cast(c.datnom % 10000 as varchar)+' '+c.fam [msg]
from dbo.nc c
join nearlogistic.marshrequests mr on mr.reqid=c.datnom and mr.reqtype=0
where mr.mhid=@mhid and c.delivcancel=0

--удаляеем годные накладные
delete from #req where [id] in (
select datnom from dbo.nc where done=1 and mhid=@mhid
)

--удаление накладных с заявками потенциально проходящими       
delete from #req where [pin] in (
select c.b_id
from dbo.nc c
left join dbo.nvzakaz z on z.datnom=c.datnom
inner join dbo.nomen n on n.hitag=z.hitag
where z.done=0 and c.mhid=@mhid 
group by c.b_id, c.sp
having isnull(sum(z.zakaz*iif(n.flgweight=1,n.netto,1)*z.price*(1+c.extra/100)),0)+c.sp>1500
)

--остались заявки, которые возвожно не поедут
if exists(select 1 from #req)
begin
 set @msg=isnull(
          stuff((select N''+[msg]+';'+char(13)+char(10)
            from #req
                  order by [id]
                for xml path(''), type).value('.','varchar(max)'),1,0,''),
           '<..>')
end

--работодатель водителя не совпадает с владельцем авто
if exists(select 1 
      from dbo.marsh m 
          join dbo.vehicle v on v.v_id=m.v_id 
          join dbo.drivers d on d.drid=m.drid 
          where m.mhid=@mhid and v.crid<>d.crid and d.crid<>1)
set @msg=@msg+'Водитель на другой машине;'+char(13)+char(10)  

if exists(select 1 from dbo.marsh where selfship=1 and mhid=@mhid) set @msg=''

set @res=cast(iif(@msg='',0,1) as bit)                 

select @res [res], @msg [msg]

if object_id('tempdb..#req') is not null drop table #req      
set nocount on
end