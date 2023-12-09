CREATE function NearLogistic.get_distance(@origin_id int, @destination_id int)
returns int
as
begin
	declare @res int, @var int
  set @res=0  
  select @var=count(*) from nearlogistic.distance a 
  where ((a.pointa=@origin_id and a.pointb=@destination_id) or (a.pointb=@origin_id and a.pointa=@destination_id)) and a.distance>0
  if @var>0 
  	select @res=min(a.distance) from nearlogistic.distance a 
    where ((a.pointa=@origin_id and a.pointb=@destination_id) or (a.pointb=@origin_id and a.pointa=@destination_id)) and a.distance>0
  return @res
end