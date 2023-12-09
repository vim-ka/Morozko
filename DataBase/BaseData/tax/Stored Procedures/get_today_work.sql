CREATE procedure tax.get_today_work
@op int,
@dt datetime,
@result_string varchar(1000) out
as 
begin
	set nocount on
  if object_id('tempdb..#today_work') is not null drop table #today_work
	select l.list, count(d.work_det_id) [cnt]
  into #today_work
  from tax.work_det d
  join tax.work_type_list l on l.id=d.work_type_id
  where d.op=@op and datediff(day,@dt,d.dt)=0
  group by l.list
  having count(d.work_det_id)>0
  set @result_string=isnull(stuff((select N''+[list]+': '+cast([cnt] as varchar)+'; ' from #today_work order by [list] for xml path(''), type).value('.','varchar(max)'),1,0,''),'')
  select list [тип], cnt [количество] from #today_work
  if object_id('tempdb..#today_work') is not null drop table #today_work
  set nocount off
end