create procedure eLoadmenager.eload_fl_waylist
@our_id int
as
begin
	select * from dbo.firmsconfig fc where our_id=@our_id
end