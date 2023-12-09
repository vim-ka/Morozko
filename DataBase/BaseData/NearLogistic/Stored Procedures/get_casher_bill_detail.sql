CREATE procedure NearLogistic.get_casher_bill_detail
@mhid int, @reqid int
as
begin
 select d.*, p1.point_adress [req_origin], p2.point_adress [req_destination],
      p_origin.point_adress [distance_origin], p_destination.point_adress [distance_destination]
  from nearlogistic.bills_det d
  join nearlogistic.marshrequests_points p1 on p1.point_id=d.p1
  join nearlogistic.marshrequests_points p2 on p2.point_id=d.p2
  join nearlogistic.marshrequests_points p_origin on p_origin.point_id=d.distance_p1
  join nearlogistic.marshrequests_points p_destination on p_destination.point_id=d.distance_p2
  where d.mhid=@mhid and d.reqid=@reqid
  order by d.ord, d.row_id
end