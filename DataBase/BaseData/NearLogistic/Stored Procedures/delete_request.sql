CREATE procedure NearLogistic.delete_request 
@request_id int
as
begin
 update f set f.isdel=1 
  from nearlogistic.marshrequests_free f where mrfID=@request_id
end;