CREATE PROCEDURE ArrivalBuh.GetIncomesList
@nd datetime,
@our int 
AS
BEGIN
  select c.*,
  		 gv.List [DCKNAME] 
  from Comman c 
  inner join DefContract dc on dc.DCK=c.DCK
  inner join FirmsConfig fc on fc.Our_id=dc.Our_id
  left join ArrivalBuh.GetVendors() gv on gv.dck=dc.DCK 
  where c.[date]=@nd
  		and fc.FirmGroup= @our
END