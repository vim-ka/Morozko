CREATE PROCEDURE ELoadMenager.eload_nl_shit_report3 @nd1 datetime, @nd2 datetime
AS 
BEGIN

--  set @nd1=convert(varchar,@nd1,104) 
--  set @nd2=convert(varchar,@nd2,104) 

	declare @with_back bit =1
  declare @dot_pay money =35.4, @dot_25_pay money =70.8, @km_pay money =18.8
  if object_id('tempdb..#mrs') is not null drop table #mrs
  if object_id('tempdb..#res') is not null drop table #res
  create table #mrs (mhid int, nd datetime, marsh int, cnt int, dots int) 
  create nonclustered index mrs_idx on #mrs(mhid)
  create table #res ([nd] datetime, [num] int, [name] varchar(50), [route] varchar(2000), [mas] decimal(15,2), [vol] decimal(15,4), 
                     [dots] int,[distance] decimal(7,2), [distance_back] decimal(7,2), [sum] money, [ord] int)
                     
  insert into #mrs 
  select m.mhid, m.nd, m.marsh, -1, -1 
         --(select count(distinct a.casher_id) from nearlogistic.bills a where a.mhid=m.mhid and a.reqid>0), 
  			 --(select count(distinct a.destination_point_id) from nearlogistic.bills a where a.mhid=m.mhid and a.reqid>0)
  from dbo.marsh m where m.nd between @nd1 and @nd2 and m.mstatus in (3,4)
	--select * from #mrs
  insert into #res(nd, num, name, route, mas, vol, ord)
  select nd,marsh,casher_name,nearlogistic.get_marsh_name(mhid),Weight,vol,
         --dots,km,back_km,sm,
         row_number() over(partition by mhid order by [nd],[marsh],[casher_name]) [ord]
  from (       
  select #mrs.nd, #mrs.marsh, #mrs.mhid,
         isnull(mc.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))) [casher_name],
         --sum(b.mas) [mas], 
         IIF(mr.ReqType=-2, ROUND(SUM(ISNULL(mrf.weight,0)),1),                                      
                           (ROUND(SUM(ISNULL(mr.Weight_,0)),1))) AS Weight,
         IIF(mr.ReqType=-2, ROUND(SUM(ISNULL(mrf.volume,0)),1),                                      
                           (ROUND(SUM(ISNULL(mr.Volume_,0)),1))) AS Vol        

  from #mrs
   LEFT JOIN NearLogistic.MarshRequests mr ON #mrs.mhid = mr.mhID 
   LEFT JOIN NearLogistic.MarshRequests_free mrf ON mr.mhID = mrf.mhID AND mr.ReqID = mrf.mrfID                                                       
   LEFT JOIN NearLogistic.marshrequests_cashers mc ON mc.casher_id = mrf.pin
   LEFT JOIN nc ON mr.ReqID = nc.DatNom AND mr.ReqType <> -2
   LEFT JOIN FirmsConfig fc ON nc.OurID = fc.Our_id

  left join dbo.defcontract dc on dc.dck = mc.casher_id   
  left join dbo.def f on f.pin=dc.pin
  --where b.bill_stack_id>0
  group by #mrs.nd, #mrs.marsh, #mrs.mhid, 
           isnull(mc.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))), 
           #mrs.dots, mr.ReqType) a
 
  select [nd] [дата], [num] [номер маршрута], [route] [маршрут], [name] [клиент], [dots] [точки], [mas] [масса], [vol] [объём] 
         --iif(@with_back=1,[distance_back],0)+[distance] [пробег], [distance_back] [пробег обратного плеча], [sum] [сумма] 
    from (
  select [nd], [num], [name], [route], [mas], [vol], [dots], [distance], [distance_back], [sum], [ord] from #res
  union all select [nd], [num], 'ИТОГО ЗА РЕЙС', null, sum([mas]), sum([vol]), sum([dots]), max([distance]), 
                   sum([distance_back]), sum([sum]), 99 from #res group by [nd], [num]) x
  order by [nd], [num], [ord]

  if object_id('tempdb..#mrs') is not null drop table #mrs
  if object_id('tempdb..#res') is not null drop table #res

END