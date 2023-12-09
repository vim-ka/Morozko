CREATE procedure NearLogistic.save_map_distance @mhid int
as
begin
  set nocount on
  declare @start_id int =0
  if object_id('tempdb..#req') is not null drop table #req  --справочник заявок
  create table #req (p1 int, p2 int, ord int)
  if object_id('tempdb..#distance') is not null drop table #distance --справочник расстояний
  create table #distance(row_id int not null identity(1,1), p1 int, p2 int, km int)

  insert into #req (p1,p2,ord)
  select p1,p2,row_number() over(order by reqorder)
  from (
  select m.point_id [p1], d.point_id [p2], r.reqorder
  from nearlogistic.marshrequests r
  join dbo.nc c on c.datnom=r.reqid
  join dbo.marsh m on m.mhid=r.mhid
  join dbo.def d on d.pin=c.b_id
  where r.mhid=@mhid and r.reqtype=0
  union all
  select m.point_id, p2.point_id, r.reqorder
  from nearlogistic.marshrequests r
  join dbo.marsh m on m.mhid=r.mhid
  join nearlogistic.marshrequests_free f on f.mrfid=r.reqid
  left join nearlogistic.marshrequestsdet p1 on p1.mrfid=f.mrfid and p1.action_id=5
  join nearlogistic.marshrequestsdet p2 on p2.mrfid=f.mrfid and p2.action_id=6
  where r.mhid=@mhid and r.reqtype=-2 and f.cost=0) a

  --вытягиваем точку старта рейса
  select @start_id=p1 from #req where ord=1;

  --вычисляем плечи
  with _p (ord,p) as (
   select ord, p2 from #req
   union all select 0, @start_id
   union all select (select max(ord)+1 from #req),@start_id
  )
  insert into #distance (p1, p2, km)
  select p1.p, p2.p, nearlogistic.get_distance(p1.p, p2.p)
  from _p p1 join _p p2 on p2.ord-1=p1.ord
  where p1.p<>p2.p order by p2.ord

  select a.*,r.distance from #distance a
  left join (select * from nearlogistic.marshrequests where mhid=@mhid) r on r.reqorder=a.row_id-1
 order by 1
  
  if object_id('tempdb..#req') is not null drop table #req  --справочник заявок
  if object_id('tempdb..#distance') is not null drop table #distance --справочник расстояний
  set nocount off
end