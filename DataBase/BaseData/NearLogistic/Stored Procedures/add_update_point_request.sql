CREATE procedure NearLogistic.add_update_point_request 
@mrdid int, @request_id int, @place int, @nd datetime, @point_id int,
@action_id int
as
begin
 if @mrdid=0
  begin
   insert into nearlogistic.marshrequestsdet (place,nd,point_id,action_id,mrfid)
    values(@place,@nd,@point_id,@action_id,@request_id)
  end
  else
   update d set d.point_id=@point_id, d.action_id=@action_id,
     d.place=@place, d.nd=@nd,
      d.mrfid=@request_id
    from nearlogistic.marshrequestsdet d
    where d.mrdid=@mrdid
end;