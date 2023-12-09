CREATE procedure NearLogistic.check_distances @mhid int
as
begin
  set nocount on  
 select p.row_id, p.p1, p.p2, nearlogistic.get_distance(p.p1, p.p2) [km]
 from NearLogistic.get_marsh_shoulders (@mhid) p
 order by p.row_id
  set nocount off
end