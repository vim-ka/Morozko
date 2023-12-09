create function NearLogistic.get_marsh_adress_string(@mrfID int)
returns varchar(2000)
as
begin
declare @way varchar(2000), @casher_id int, @mhid int

select @casher_id=pin,@mhid=mhid
from nearlogistic.marshrequests_free 
where mrfid=@mrfID

select @way=isnull('['+p.point_adress+']>>','')
from dbo.marsh m
join nearlogistic.marshrequests_points p on m.point_id=p.point_id
where m.mhid=@mhid

select @way=@way+stuff((
	select N'>>['+p.point_adress+']'
	from nearlogistic.marshrequests_free f 
  join nearlogistic.marshrequestsdet t on t.mrfid=f.mrfid
	join nearlogistic.marshrequests_points p on p.point_id=t.point_id
	where f.mhid=@mhid and f.pin=@casher_id and t.action_id=6
	order by t.place
	for xml path(''), type).value('.','varchar(max)'),1,2,'')
  
return isnull(@way,'')
end