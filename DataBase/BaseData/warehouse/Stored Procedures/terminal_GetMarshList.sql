CREATE PROCEDURE warehouse.terminal_GetMarshList
@nd datetime,
@skladlist varchar(1000),
@mhid int =0
with recompile
AS
BEGIN
declare @normal_count int
declare @terminated_count int
declare @terminal varchar(10)
declare @nd1 datetime
declare @nd2 datetime

set @normal_count=130
set @terminal = host_name()

declare @dt1 datetime
declare @dt2 datetime

if convert(varchar,getdate(),108) between '09:00:00' and '20:59:59'
begin
	set @dt1=convert(varchar,getdate(),104)+' 09:00:00'
	set @dt2=convert(varchar,getdate(),104)+' 20:59:59'  
end 
else
begin
	set @dt1=convert(varchar,dateadd(day,-1,getdate()),104)+' 21:00:00'
	set @dt2=convert(varchar,getdate(),104)+' 08:59:59'  
end 

select  @terminated_count=
				count(distinct z.datnom) 
from dbo.nvzakaz z 
where z.dtEnd+z.tmEnd between @dt1 and @dt2 and z.done=1 
			and (z.comp like '%'+@terminal or z.comp like '%'+@terminal+'@cancel')

if object_id('tempdb..#skladlist') is not null drop table #skladlist
if object_id('tempdb..#zakaz') is not null drop table #zakaz
if object_id('tempdb..#marshs') is not null drop table #marshs
if object_id('tempdb..#reqs_string') is not null drop table #reqs_string

create table #skladlist (id int)

insert into #skladlist
select *
from string_split(@skladlist,',') x

select iif(c.mhid=0,isnull(sr.sregionid,0),iif(m.selfship=1,-99,c.mhid)) [mhid],
			 z.datnom,
			 z.done,
       iif(z.done=1 and z.ID=0,0,iif(n.flgWeight=1,z.Zakaz*n.netto,z.curWeight)) [mas],
       isnull(sr.sregName,0) [reg_id],
       z.skladNo
into #zakaz
from morozdata.dbo.nvzakaz z
join #skladlist s on s.id=z.skladNo
join morozdata.dbo.nc c on c.datnom=z.datnom
join morozdata.dbo.nomen n on n.hitag=z.hitag
join morozdata.dbo.def d on d.pin=c.b_id
left join morozdata.dbo.Regions r on r.reg_id=d.reg_id 
left join morozdata.warehouse.skladreg sr on sr.sregionID=r.sregionID
left join (select * from morozdata.dbo.marsh where mhid>0) m on m.mhid=c.mhid
where z.nd=@nd
			and c.mhid=iif(@mhid>1000,@mhid,c.mhid)			

create table #marshs ([time] varchar(10),
											[direction] varchar(500),
                      [vdirection] varchar(500),
                      [regions] varchar(500),
                      [terminals] varchar(500),
                      [status] varchar(500),
                      [nakl] int,
                      [nakl_done] int,
                      [nakl_not] int,
                      [mhid] int,
                      [mas] decimal(15,2),
                      [mas_done] decimal(15,2),
                      [mas_not] decimal(15,2),
                      [skladlist] varchar(500),
                      [RowID] int,
                      [marsh] varchar(3))

insert into #marshs ([mhid])
select distinct mhid from #zakaz 

if @mhid>1000 or @mhid=0
insert into #marshs ([mhid])
select -1

select z.mhid,
	 		 stuff(
       (select N'['+a.reg_id+']'
        from #zakaz a
        where a.mhid=z.mhid
        group by a.reg_id
        for xml path(''), type).value('.','varchar(max)'),1,0,'') [regs]
into #reqs_string        
from #zakaz z
where mhid>1000 
group by z.mhid


update t set t.[time]=iif(t.mhid<1000,'--:--',left(iif(isnull(m.TimePlan,0)='0','00:00',iif(len(m.TimePlan)=7,'0','')+m.TimePlan),5)),
						 t.[direction]=case when t.mhid between 0 and 1000 then 'Регионы'
             							      when t.mhid=-1 then 'Все заявки [осталось обработать '+cast(@normal_count-isnull(@terminated_count,0) as varchar)+']'
                                when t.mhid=-99 then 'Самовывоз'
                                else '#'+cast(m.marsh as varchar)+' '+isnull(m.direction,'') end,             
             t.[vdirection]=isnull(rs.regs+' ','')+isnull(rg.[RegName],'<..>'),
             t.[regions]=isnull(rg.[sReg_ID],sr.sregName),
             t.[status]=case when t.mhid between 0 and 1000 then 'Регионы'
             							   when t.mhid=-1 then 'Все заявки'
                             when t.mhid=-99 then 'Самовывоз'
                             else isnull(ms.msname,'<..>')+' '+isnull(d.fio,'<..>') end,
             t.[nakl]=isnull((select count(distinct datnom) from #zakaz where #zakaz.mhid=iif(t.mhid=-1,#zakaz.mhid,t.mhid)),0),
             t.[nakl_not]=isnull((select count(distinct datnom) from #zakaz where #zakaz.mhid=iif(t.mhid=-1,#zakaz.mhid,t.mhid) and #zakaz.done=0),0),
             t.[mas]=isnull((select sum(cast(mas as decimal(15,0))) from #zakaz where #zakaz.mhid=iif(t.mhid=-1,#zakaz.mhid,t.mhid)),0),
             t.[mas_done]=isnull((select sum(cast(mas as decimal(15,0))) from #zakaz where #zakaz.mhid=iif(t.mhid=-1,#zakaz.mhid,t.mhid) and #zakaz.done=1),0),
             t.[mas_not]=isnull((select sum(cast(mas as decimal(15,0))) from #zakaz where #zakaz.mhid=iif(t.mhid=-1,#zakaz.mhid,t.mhid) and #zakaz.done=0),0),
             t.[skladlist]=isnull(stuff((select N','+cast(z.skladNo as varchar) 
             														 from #zakaz z 
                                         where z.mhid=iif(t.mhid=-1,z.mhid,t.mhid)
                                         group by z.Skladno
                                         order by z.Skladno
                                         for xml path(''), type).value('.','varchar(max)'),1,1,''),
                                         '<..>'),
             t.[terminals]='<..>',
             t.[RowID]=isnull(iif(sr.sregionID is null,9999,sr.priority),0),
             t.[marsh]=case when t.mhid in (-1,-99) then '---'
             						 		when t.mhid between 0 and 1000 then sr.sregName
                            else cast(m.marsh as varchar) end                             
from #marshs t
left join morozdata.dbo.Marsh m on m.mhid=t.mhid
left join morozdata.nearlogistic.GetRegsString(@nd) rg on rg.mhid=t.mhid
left join morozdata.nearlogistic.marshstatus ms on ms.msid=m.mstatus
left join #reqs_string rs on rs.mhid=t.mhid
--left join morozdata.dbo.regions r on r.regionid=t.mhid 
left join morozdata.dbo.drivers d on d.drid=m.drid 
left join morozdata.warehouse.skladreg sr on sr.sregionID=t.mhid

update t set t.[nakl_done]=t.[nakl]-t.[nakl_not],
						 t.[RowID]=x.[ord]
from #marshs t
join (
select a.mhid,
			 case when a.mhid=-99 then -99
  					when a.mhid=-1 then 0
            when a.mhid between 0 and 1000 then 1000+a.[RowID]
            else row_number() over(order by iif(substring(a.[time],1,1)='0','1','0')+a.[time],m.[marsh]) end [ord]
from #marshs a
left join morozdata.dbo.marsh m on a.mhid=m.mhid) x on x.mhid=t.mhid

select * from #marshs order by [RowID]

if object_id('tempdb..#reqs_string') is not null drop table #reqs_string
if object_id('tempdb..#skladlist') is not null drop table #skladlist
if object_id('tempdb..#zakaz') is not null drop table #zakaz
if object_id('tempdb..#marshs') is not null drop table #marshs
END