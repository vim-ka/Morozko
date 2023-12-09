CREATE PROCEDURE NearLogistic.PrintStackWarranty
@mhID int
AS
BEGIN
  select  cast(p.datnom as varchar) [datnom], 
       d.pin, 
          d.gpName, 
          max(p.Printcount) as Printcount, 
          n.nd, 
          m.marsh,
          --'600'+right('0000000'+cast(m.mhid as varchar),8) [barCode]
          '12'+format(n.nd,'ddMMyy')+RIGHT('0000'+CAST(m.Marsh AS VARCHAR(4)),4) [Barcode],
          7 gpOur_ID,
          cast('' as varchar(15)) [fName],
          t.legend [type_waranty]
  from dbo.Dover2PrintLog p 
  join dbo.nc n on p.datnom=n.datnom 
  join dbo.Def d on n.b_id=d.pin
  join [NearLogistic].MarshRequests r on n.datnom=r.ReqID and r.ReqType=0
  join dbo.Marsh m on r.mhid=m.mhid
  left join dbo.Dover2PrintLog_Type t on t.dover_type=p.dover_type
  where r.mhid=@mhid
  group by  p.datnom, d.pin, d.gpName, n.nd, m.mhid, m.marsh, n.gpOur_ID,t.legend
  
  union all
  
  select  max(n.StfNom) [StfNom], 
       d.pin, 
          d.gpName, 
          1 as Printcount, 
          n.nd, 
          m.marsh,
          --'600'+right('0000000'+cast(m.mhid as varchar),8) [barCode]
          '12'+format(n.nd,'ddMMyy')+RIGHT('0000'+CAST(m.Marsh AS VARCHAR(4)),4) [Barcode],
          n.gpOur_ID,
          '"Хлебпром"' [fName],
          '' [type_waranty]
  from dbo.nc n 
  join dbo.Def d on n.b_id=d.pin
  join [NearLogistic].MarshRequests r on n.datnom=r.ReqID and r.ReqType=0
  join dbo.Marsh m on r.mhid=m.mhid 
  where r.mhid=@mhid
     and n.stip=4
        and n.gpOur_ID=36869
  group by d.pin, d.gpName, n.nd, m.mhid, m.marsh, n.gpOur_ID
END