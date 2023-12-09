CREATE PROCEDURE ArrivalBuh.GetRequestsList
@our int
AS
BEGIN
  	select p.*,
    	   gv.List [DCKNAME]
	from PrihodReq p
	inner join DefContract dc on dc.DCK=p.PrihodRDefContract
	inner join FirmsConfig fc on fc.Our_id=dc.Our_id and fc.FirmGroup= @our
    left join ArrivalBuh.GetVendors() gv on gv.dck=dc.DCK
	where cast(p.PrihodRDate as date)=cast(getdate() as date) 
			or p.PrihodRSaveTo=1
      
END