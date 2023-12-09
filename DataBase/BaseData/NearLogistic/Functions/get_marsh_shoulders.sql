CREATE function NearLogistic.get_marsh_shoulders (@mhid int)
returns @res table(row_id int, p1 int, p2 int)
as
begin
	declare @point_id int, @max_ord int
  declare @p table (p int, ord int)
  
  select @point_id=point_id from dbo.marsh where mhid=@mhid
  
  insert into @p
  select p2,row_number() over(order by reqorder)
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
  where r.mhid=@mhid and r.reqtype=-2 and f.cost=0
  union all select 0, @point_id, 999
  union all select 0, @point_id, 0) a
  
  insert into @res 
  select row_number() over(order by p2.ord), p1.p, p2.p
  from @p p1 join @p p2 on p2.ord-1=p1.ord
  where p1.p<>p2.p
	
  return
end