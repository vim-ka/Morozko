create procedure nearlogistic.delete_point_request 
@mrdid int
as
begin
 delete from nearlogistic.marshrequestsdet where mrdid=@mrdid
end;