CREATE procedure ELoadMenager.eload_nl_marshs_for_graphics
@nd1 datetime, @nd2 datetime
as
begin
	select m.mhid, m.nd, m.marsh, iif(v.crid=7,0,l.dist) [dist], iif(v.crid=7,0,l.weight) [weight],
  			 round(iif(v.crid=7,0,iif(l.weight>0,(l.oplatasum+l.oplataother)/l.weight,0)),2) [cost1kg],
         iif(v.crid<>7,0,l.dist) [dist_morozko], iif(v.crid<>7,0,l.weight) [weight_morozko],
  			 round(iif(v.crid<>7,0,iif(l.weight>0,(l.oplatasum+l.oplataother)/l.weight,0)),2) [cost1kg_morozko],
           iif(m.direction is null,'',m.direction+' ')+nearlogistic.GetMarshRegString(m.mhid) [direction]  
	from dbo.marsh m
  join dbo.vehicle v on v.v_id=m.v_id
  join nearlogistic.nllistpaydet l on l.mhid=m.mhid
  where m.nd between @nd1 and @nd2 and m.listno>0
end