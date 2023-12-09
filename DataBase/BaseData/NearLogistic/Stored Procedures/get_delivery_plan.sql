CREATE procedure NearLogistic.get_delivery_plan @day int, @group_type int, @avg_weight float, @marsh int
as
begin
  if object_id('tempdb..#res') is not null drop table #res
  if object_id('tempdb..#reg') is not null drop table #reg

  select dp.*, c.casher_name, p.point_adress, a.periodic, isnull(r.place,'не определен') [place], isnull(r.reg_id,'<..>') [reg_id]
  into #res
  from nearlogistic.delivery_plan dp
  join nearlogistic.marshrequests_points p on p.point_id=dp.point_id
  join nearlogistic.marshrequests_cashers c on c.casher_id=dp.casher_id
  join nearlogistic.periodics a on a.id=dp.day_periodic
  left join dbo.regions r on r.reg_id=p.reg_id
  where dp.delivery_day in (0,@day)

  if @group_type=0 select * from #res where marsh_number=0 --без группировки без маршрута
  if @group_type=1 select reg_id, place, count(distinct point_id) [cnt], count(dpid)*@avg_weight [mas] --группировка по областям
                   from #res where marsh_number=0 group by reg_id, place
  if @group_type=2 begin --группировка по маршрутам
    select distinct
           a.marsh_number,
           stuff((select N','+b.place
                  from #res b where b.marsh_number=a.marsh_number
                  group by b.place for xml path(''), type
                  ).value('.','varchar(max)'),1,1,'') [places]
    into #reg
    from #res a
    where a.marsh_number>0

    select #res.marsh_number, isnull(#reg.places,'<..>') [places], count(distinct point_id) [cnt], count(dpid)*@avg_weight [mas]                 
    from #res left join #reg on #reg.marsh_number=#res.marsh_number where #res.marsh_number>0 group by #res.marsh_number, isnull(#reg.places,'<..>')
  end  
  if @group_type=3 select * from #res where marsh_number=@marsh --без группировки крнкретный маршрут

  if object_id('tempdb..#res') is not null drop table #res
  if object_id('tempdb..#reg') is not null drop table #reg
end