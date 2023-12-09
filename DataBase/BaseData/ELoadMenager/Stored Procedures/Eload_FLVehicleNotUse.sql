CREATE PROCEDURE ELoadMenager.Eload_FLVehicleNotUse
@nd datetime
AS
BEGIN
set nocount on
if object_id('tempdb..#veh') is not null drop table #veh
if object_id('tempdb..#msh') is not null drop table #msh
if object_id('tempdb..#rsp') is not null drop table #rsp

select m.marsh, m.v_id  
into #msh
from dbo.marsh m
where m.nd=@nd and m.selfship=0 and m.v_id>0

select distinct
			 v.v_id,
       v.model+' '+v.regnom [vehname],
       cast(iif(v.crid=7,1,0) as bit) [isMorozko],
			 isnull((
       case when x.tmwork='00:00' then 'V'
            when v.v_id is null then 'X'
            when x.reserve=1 then 'R'
            else rtrim(ltrim(x.tmWork)) end),'') [rsp]
into #rsp            
from dbo.vehicle v
left join dbo.vehrasp x on v.v_id=x.v_id and x.nd=@nd
where v.closed=0 and v.trailer=0 and v.v_id>0

select v.v_id,
		   v.[vehname],
       isnull(
       stuff((select N''+isnull(d.fio,'<..>')+', '+isnull(d.phone,'<..>')+';'+char(13)+char(10)
							from dbo.drivers d 
							where d.v_id=v.v_id
							order by d.fio 
						  for xml path(''), type).value('.','varchar(max)'),1,0,'')
       ,'') [drv],
       v.[isMorozko],
       v.[rsp],
       isnull(
       stuff((select N','+cast(x.marsh as varchar)
							from #msh x 
							where x.v_id=v.v_id
							order by x.marsh 
						  for xml path(''), type).value('.','varchar(max)'),1,1,'')
       ,'') [msh]
into [#veh]       
from #rsp v

select [vehname] [Автомобиль],
			 [drv] [Водители],
       [isMorozko] [Наш],
       [msh] [Маршруты],
       [rsp] [Календарь] 
from #veh
order by ismorozko desc, vehname

if object_id('tempdb..#veh') is not null drop table #veh
if object_id('tempdb..#msh') is not null drop table #msh
if object_id('tempdb..#rsp') is not null drop table #rsp
set nocount off
END