CREATE procedure NearLogistic.get_casher_bill
@mhid int, @casher_id int
as
begin
 select b.bill_id, b.bill_stack_id, b.mhid, b.reqid, b.origin_point_id, p1.point_adress [origin], b.destination_point_id, p2.point_adress [destination], 
      b.distance, b.mas, b.vol, b.req_pay, b.nal
  from nearlogistic.bills b
  join nearlogistic.marshrequests_points p1 on p1.point_id=b.origin_point_id
  join nearlogistic.marshrequests_points p2 on p2.point_id=b.destination_point_id
  where b.mhid=@mhid and b.casher_id=@casher_id
  group by b.bill_id, b.bill_stack_id, b.mhid, b.reqid, b.origin_point_id, p1.point_adress, b.destination_point_id, p2.point_adress, b.distance, b.mas, b.vol, b.req_pay, b.nal
  order by b.reqid
end