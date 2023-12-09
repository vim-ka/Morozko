CREATE procedure ELoadMenager.eload_nl_shit_report2 @nd1 datetime, @nd2 datetime
as
begin
  select m.nd, m.marsh, isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))) [casher_name], 
         d.row_id, p1.point_adress [origin], p2.point_adress [destination],
         sum(d.mas) [mas], sum(d.vol) [vol], max(d.km / 1000.0) [distance], sum(d.req_pay) [sum]
  from NearLogistic.bills_det d
  join dbo.marsh m on d.mhid=m.mhid
  join NearLogistic.marshrequests_points p1 on p1.point_id=d.distance_p1
  join NearLogistic.marshrequests_points p2 on p2.point_id=d.distance_p2
  left join nearlogistic.marshrequests_cashers c on c.casher_id=d.casher_id and d.is_old=0
  left join dbo.firmsconfig fc on fc.our_id=d.casher_id and d.is_old=1
  left join dbo.defcontract dc on dc.dck=d.casher_id and d.is_old=1
  left join dbo.def f on f.pin=dc.pin
  where m.nd between @nd1 and @nd2
  group by m.nd, m.marsh, isnull(c.casher_name,isnull(fc.ourname,isnull(f.gpname,f.brname))),
           d.row_id, p1.point_adress, p2.point_adress
  order by 1,2,3,4         
end