CREATE function NearLogistic.get_free_adress_string(@mrfID int, @tip int =0)
returns varchar(500)
as
begin
declare @way varchar(500)

select @way=stuff((
	select N'>>['+p.point_adress+']'
	from nearlogistic.marshrequestsdet t
	join nearlogistic.marshrequests_points p on p.point_id=t.point_id
	where t.mrfid=@mrfid and t.action_id=iif(@tip=0,t.action_id,@tip)
	order by t.place
	for xml path(''), type).value('.','varchar(max)'),1,2,'')
  
return isnull(@way,'')
end