CREATE procedure ELoadMenager.eload_nl_shit_report @nd1 datetime, @nd2 datetime, @break bit =0
as
begin
	declare @with_back bit =1
  set nocount on
  declare @dot_pay money =35.4, @dot_25_pay money =70.8, @km_pay money =18.8
  if object_id('tempdb..#mrs') is not null drop table #mrs
  if object_id('tempdb..#res') is not null drop table #res
  create table #mrs (mhid int, nd datetime, marsh int, cnt int, dots int) 
  create nonclustered index mrs_idx on #mrs(mhid)
  create table #res ([nd] datetime, [num] int, [name] varchar(50), [route] varchar(2000), [mas] decimal(15,2), [vol] decimal(15,4), 
                     [dots] int,[distance] decimal(7,2), [distance_back] decimal(7,2), [sum] money, [ord] int)
                     
  insert into #mrs 
  select m.mhid, m.nd, m.marsh, (select count(distinct a.casher_id) from nearlogistic.bills a where a.mhid=m.mhid and a.reqid>0), 
  			 (select count(distinct a.destination_point_id) from nearlogistic.bills a where a.mhid=m.mhid and a.reqid>0)
  from dbo.marsh m where m.nd between @nd1 and @nd2 and m.mstatus in (3,4)
	--select * from #mrs
  insert into #res
  select nd,marsh,casher_name,nearlogistic.get_marsh_name(mhid),mas,vol,dots,km,back_km,sm,
         row_number() over(partition by mhid order by [nd],[marsh],[casher_name]) [ord]
  from (       
  select #mrs.nd, #mrs.marsh, #mrs.mhid,
         isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))) [casher_name],
         sum(b.mas) [mas], sum(b.vol) [vol],
         cast(max(b.distance / 1000.0) as decimal(15,2)) [km], 
         iif(@break=0,
         		 cast(min(iif(b.reqid=-1 and isnull(#mrs.cnt,0)>0,(b.distance / #mrs.cnt / 1000.0),null)) as decimal(15,4)), --для четких
             cast((
             			 --(sum(b.req_pay) - iif(#mrs.dots>25,@dot_25_pay,@dot_pay)*count(distinct b.destination_point_id) - max(b.distance / 1000.0)*@km_pay) / @km_pay
                   iif(@km_pay=0,0,(sum(b.req_pay) - iif(#mrs.dots>25,@dot_25_pay,@dot_pay)*count(distinct b.destination_point_id)) / @km_pay)
                   ) as decimal(15,4))  -- для не очень
         ) [back_km], 
         sum(b.req_pay) sm, count(distinct b.destination_point_id) [dots]
  from nearlogistic.bills b
  join #mrs on #mrs.mhid=b.mhid
  left join nearlogistic.marshrequests_cashers c on c.casher_id=b.casher_id and b.is_old=0
  left join dbo.firmsconfig fc on fc.our_id=b.casher_id and b.is_old=1
  left join dbo.defcontract dc on dc.dck=b.casher_id and b.is_old=1
  left join dbo.def f on f.pin=dc.pin
  --where b.bill_stack_id>0
  group by #mrs.nd, #mrs.marsh, #mrs.mhid, isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))), #mrs.dots) a

  select [nd] [дата], [num] [номер маршрута], [route] [маршрут], [name] [клиент], [dots] [точки], [mas] [масса], [vol] [объём], iif(@with_back=1,[distance_back],0)+[distance] [пробег], [distance_back] [пробег обратного плеча], [sum] [сумма] from (
  select [nd], [num], [name], [route], [mas], [vol], [dots], [distance], [distance_back], [sum], [ord] from #res
  union all select [nd], [num], 'ИТОГО ЗА РЕЙС', null, sum([mas]), sum([vol]), sum([dots]), max([distance]), sum([distance_back]), sum([sum]), 99 from #res group by [nd], [num]) x
  order by [nd], [num], [ord]

  if object_id('tempdb..#mrs') is not null drop table #mrs
  if object_id('tempdb..#res') is not null drop table #res
  set nocount off
end