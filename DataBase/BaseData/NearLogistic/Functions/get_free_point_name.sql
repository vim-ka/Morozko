CREATE function NearLogistic.get_free_point_name(@reqid int, @type int)
returns varchar(50)
as
begin
	declare @res varchar(50)
  set @res=
  (
  select top 1 case when @type = 0 then cast(p.point_id as varchar)+'#'+p.point_name
  								  when @type = 1 then cast(p.point_id as varchar)
                    when @type = 2 then p.point_name end
  from nearlogistic.marshrequestsdet d 
  join nearlogistic.marshrequests_points p on p.point_id=d.point_id
  where d.action_id=6 and d.mrfid=@reqid order by d.place desc
  )
  return @res
end