CREATE procedure NearLogistic.calculate_prebill @mhid int, @debug bit =0, @error int out, @msg varchar(500) out
as  --рассчет по типу "КАК ПЛОХО БЫТЬ ПОСЛЕДНИМ"  
begin
set nocount ON 
--переменные для рассчета
declare @koef decimal(15,4), @delivpay money, @tax money, @start_id int, @km int, @km_cost money, @count_casher int,
				@calculate_type int, @tranname varchar(50), @fixed_req bit =0, @dist float =0, @bill_stack int =0

set @error=0; set @msg='';	set @tranname='NearLogistic.calculate_prebill_'+cast(@mhid as varchar);
set @fixed_req=cast(iif(exists(select 1 from nearlogistic.marshrequests_free where mhid=@mhid and cost<>0),1,0) as bit)
select @dist=calcdist from dbo.marsh where mhid=@mhid

--дополнительные сущности для рассчтета
if object_id('tempdb..#req') is not null drop table #req  --справочник заявок
create table #req (reqid int, casher_id int, mas decimal(15,4), vol decimal(15,4), p1 int, p2 int, ord int, is_old bit)
if object_id('tempdb..#distance') is not null drop table #distance --справочник расстояний
create table #distance(row_id int not null identity(1,1), p1 int, p2 int, km int, tax money)
if object_id('tempdb..#result') is not null drop table #result --результирующая таблица
create table #result (reqid int, casher_id int, mas decimal(15, 4), vol decimal(15, 4), p1 int, p2 int, ord int, is_old bit, row_id int, 
											distance_p1 int, distance_p2 int, km int, tax money, distance_mas decimal(15, 4),
											distance_vol decimal(15, 4),vol_cost money,mas_cost money,req_pay money)
if object_id('tempdb..#back_way') is not null drop table #back_way --возвратное плечо таблица
create table #back_way (reqid int, casher_id int, mas decimal(15, 4), vol decimal(15, 4), p1 int, p2 int, ord int, is_old bit, row_id int, 
											distance_p1 int, distance_p2 int, km int, tax money, distance_mas decimal(15, 4),
											distance_vol decimal(15, 4),vol_cost money,mas_cost money,req_pay money)                      

--вычисляем затраты на рейс
select @delivpay= [nearlogistic].marsh1calcfact(@mhid,2,@dist);
exec [nearlogistic].FinCalc @mhid,@delivpay,0,@tax out

--вытягиваем все заявки из рейса
insert into #req (reqid,casher_id,mas,vol,p1,p2,is_old,ord)
select reqid,casher_id,mas,vol,p1,p2,is_old,row_number() over(order by reqorder)
from (
select r.reqid, case when c.stip=4 then c.gpour_id else c.ourid end casher_id, r.weight_ mas, r.volume_ vol, m.point_id [p1],
       d.point_id [p2], cast(1 as bit) [is_old], r.reqorder, r.mhid
from nearlogistic.marshrequests r
join dbo.nc c on c.datnom=r.reqid
join dbo.marsh m on m.mhid=r.mhid
join dbo.def d on d.pin=c.b_id
where r.mhid=@mhid and r.reqtype=0
union all
select r.reqid, f.pin, r.weight_, r.volume_, m.point_id, p2.point_id, cast(0 as bit), r.reqorder, r.mhid
from nearlogistic.marshrequests r
join dbo.marsh m on m.mhid=r.mhid
join nearlogistic.marshrequests_free f on f.mrfid=r.reqid
left join nearlogistic.marshrequestsdet p1 on p1.mrfid=f.mrfid and p1.action_id=5
join nearlogistic.marshrequestsdet p2 on p2.mrfid=f.mrfid and p2.action_id=6
where r.mhid=@mhid and r.reqtype=-2 and f.cost=0) a

--select @bill_stack=bill_stack_id from nearlogistic.bills where mhid=@mhid;
select @bill_stack=bill_stack_id from nearlogistic.billsSum where mhid=@mhid;
if @bill_stack<>0 set @error=@error + 8;

if not exists(select 1 from #req) and @fixed_req=0 set @error=@error+1

--вытягиваем точку старта рейса
select @start_id=p1 from #req where ord=1;

if @start_id is null set @error=@error+2;

insert into #distance (p1, p2, km)
select p.p1, p.p2, nearlogistic.get_distance(p.p1, p.p2)
from NearLogistic.get_marsh_shoulders (@mhid) p
order by p.row_id

--вычисляем суммарный пробег
select @km=sum(km) from #distance

if isnull(@km,0)=0 set @error=@error+4

--стоимость километра
if @km=0 set @km_cost = 0
else set @km_cost = @delivpay / @km

--вычисляем ставки по плечам
update d set d.tax=d.km*@km_cost from #distance d

if @debug=1
begin
	select * from #req
	select * from #distance
  select distance,* from nearlogistic.marshrequests where mhid=@mhid
end

--заполняем результирующую таблицу
insert into #result (reqid, casher_id, mas, vol, p1, p2, ord, is_old, row_id, distance_p1, distance_p2, km, tax, distance_mas)
select r.reqid, r.casher_id, r.mas, r.vol, r.p1, r.p2, r.ord, r.is_old, d.row_id, d.p1, d.p2, d.km, d.tax, 0 from #req r 
join #distance d on d.row_id between (select min(a.row_id) 
                                        from #distance a where a.p1=r.p1) and 
                                     (select min(a.row_id) from #distance a where a.p2=r.p2)

--вычисляем массу на плече
update r set r.distance_mas=a.mas, r.distance_vol=a.vol
from #result r 
join (select row_id, sum(mas) [mas], sum(vol) [vol] from #result group by row_id) a on a.row_id=r.row_id


--вычисляем таксу за 1 кг на плече
update r set r.vol_cost=iif(isnull(r.distance_vol,0) <= 0,0,(r.tax / r.distance_vol) * r.vol),
						 r.mas_cost=iif(isnull(r.distance_mas,0) <= 0,0,(r.tax / r.distance_mas) * r.mas)
from #result r

select @calculate_type=cast(val as int) from dbo.config where param='LogisticCalculateType'
set @calculate_type=isnull(@calculate_type,0)

--вычисляем стоимость заявки
update r set r.req_pay =case when @calculate_type=0 then r.mas_cost
														 when @calculate_type=1 then r.vol_cost
                             when @calculate_type=2 then iif(r.vol_cost>r.mas_cost,r.vol_cost,r.mas_cost)
                             else 0 end
from #result r

if @error=0 or @fixed_req=1
begin
  begin tran @tranname
  --сохранение рассчетов
  delete from nearlogistic.bills where mhid=@mhid
  delete from nearlogistic.bills_det where mhid=@mhid 
 	
  if @error=0
  begin
  	--сохранение детализации для счета
  	insert into nearlogistic.bills_det select @mhid, * from #result
  	insert into nearlogistic.bills(mhid, reqid, casher_id, mas, vol, distance, origin_point_id, destination_point_id, is_old, tax, req_pay)
  	select @mhid, reqid, casher_id, min(mas), min(vol), sum(km), p1, p2, is_old, sum(tax), sum(req_pay)
  	from #result group by reqid, casher_id, p1, p2, is_old
    --запись начисление за обратное плечо  
    set @count_casher=(select count(distinct casher_id) from #req)
    if @count_casher>0
    begin
      insert into #back_way
      select -1 [reqid], a.casher_id, 0 [mas], 0 [vol], d.p1, d.p2, 999 [ord], a.is_old, 999 [row_id], d.p1 [distance_p1], d.p2 [distance_p1], d.km, d.tax / @count_casher [tax], 
             0 [distance_mas], 0 [distance_vol], 0 [vol_cost], 0 [mas_cost], d.tax / @count_casher [req_pay]
      from #distance d
      join (select distinct casher_id, is_old from #req) a on 1=1
      where row_id=(select max(row_id) from #distance)
        
      insert into nearlogistic.bills_det select @mhid, * from #back_way
      insert into nearlogistic.bills(mhid, reqid, casher_id, mas, vol, distance, origin_point_id, destination_point_id, is_old, tax, req_pay)
      select @mhid, reqid, casher_id, min(mas), min(vol), sum(km), p1, p2, is_old, sum(tax), sum(req_pay)
      from #back_way group by reqid, casher_id, p1, p2, is_old
    end  
  end
	
  --сохранение детализации для фиксированных счетов
	insert into nearlogistic.bills(mhid, reqid, casher_id, mas, vol, distance, origin_point_id, destination_point_id, is_old, tax, req_pay, nal)
  select f.mhid, f.mrfid, f.pin, f.weight, f.volume, 0, 
       isnull((select top 1 point_id from nearlogistic.marshrequestsdet where mrfid=f.mrfid and action_id=5),m.point_id),
       (select top 1 point_id from nearlogistic.marshrequestsdet where mrfid=f.mrfid and action_id=6),
       0,0,f.cost,f.nal
  from nearlogistic.marshrequests_free f
  join dbo.marsh m on m.mhid=f.mhid
  where f.mhid=@mhid and f.cost<>0
	
  if @@trancount>0 commit tran @tranname
	else rollback tran @tranname
end

if @error & 1 <> 0 set @msg=@msg+char(13)+'нет заявок;'
if @error & 2 <> 0 set @msg=@msg+char(13)+'не определена точка старта;'
if @error & 4 <> 0 set @msg=@msg+char(13)+'нулевой пробег;'
if @error & 8 <> 0 set @msg=@msg+char(13)+'маршрут рассчитан и занесен в реестр №'+cast(@bill_stack as varchar)+';'

if @debug=1
begin
	select * from #result
  
  set @count_casher=(select count(distinct casher_id) from #req)
  if @count_casher>0  
  select -1 [reqid],a.casher_id,0 [mas], 0 [vol], d.p1, d.p2, 999 [ord], a.is_old, 999 [row_id], d.p1 [distance_p1], d.p2 [distance_p1], d.km, d.tax / @count_casher [tax], 
  			 0 [distance_mas], 0 [distance_vol], 0 [vol_cost], 0 [mas_cost], d.tax / @count_casher [req_pay]
  from #distance d
  join (select distinct casher_id, is_old from #req) a on 1=1
  where row_id=(select max(row_id) from #distance)
end  

if object_id('tempdb..#req') is not null drop table #req
if object_id('tempdb..#distance') is not null drop table #distance
if object_id('tempdb..#result') is not null drop table #result
set nocount off
end