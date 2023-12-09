CREATE FUNCTION ArrivalBuh.GetVendors()
RETURNS TABLE
AS
--BEGIN
  RETURN
  	select dc.dck, cast(d.Ncod as varchar)+'# '+d.brName+': дог. '+isnull(dc.ContrName,'<не указан>')+' '+f.OurName [List], cast(0 as bit) [isSafe], d.pin, d.ncod, f.our_id
	from defcontract dc 
	left join FirmsConfig f on f.our_id=dc.our_id
	join def d on d.ncod=dc.pin
    where dc.contrtip=1 
    union all 
    select dc.dck, cast(d.pin as varchar)+'# '+d.brName+': дог. '+isnull(dc.ContrName,'<не указан>')+' '+f.OurName, cast(1 as bit), d.pin, d.ncod, f.our_id
    from defcontract dc 
    join def d on d.pin=dc.pin
    left join FirmsConfig f on f.our_id=dc.our_id
    where dc.contrtip in (5,6)
    union all
	select null, '<не указан договор>', cast(0 as bit),0,0,0
--END