CREATE PROCEDURE NearLogistic.GetMarshStatics
@mhID INT 
AS 
BEGIN
  DECLARE @sert INT 
  DECLARE @tipr varchar(10)
  declare @warranty_count INT
  DECLARE @warrantyGoods_count INT
  declare @back_count int
  
  select @warranty_count=count(distinct p.datnom)
  from Dover2PrintLog p 
  join [NearLogistic].MarshRequests r on p.datnom=r.ReqID and r.ReqType=0
  where r.mhid=@mhid
    AND p.dover_type <> 2 

  select @warrantyGoods_count=count(distinct p.datnom)
  from Dover2PrintLog p 
  join [NearLogistic].MarshRequests r on p.datnom=r.ReqID and r.ReqType=0
  where r.mhid=@mhid
    AND p.dover_type = 2 
	
  select @back_count=count(r.reqid) 
  from [NearLogistic].MarshRequests r
  where r.mhid=@mhid
  			and r.ReqType=1

  SELECT @sert=IIF(MAX(c.SertifDoc)>0,1,0) 
  FROM NearLogistic.MarshRequests mr
  INNER JOIN dbo.nc c ON c.DatNom=mr.ReqID
  WHERE mr.ReqType=0
        AND mr.mhID=@mhID
  
  SELECT TOP 1 @tipr=d.Reg_ID
  FROM NearLogistic.MarshRequests mr
  INNER JOIN def d ON d.pin=mr.PINTo
  WHERE mr.mhID=@mhID
	
  SELECT m.Marsh,
         CONVERT(VARCHAR,m.nd,104) [nd],
         m.Dist,
         sum(mr.Weight_) [Weight],
         IIF(sum(mr.Weight_)<1000,1000,sum(mr.Weight_)) [Weight2],
         v.RegNom,
         v.Model, 
         d.Fio+' '+d.Phone [DrvN],
         s.Fio+' '+s.Phone [Sped],
         '12'+format(m.nd,'ddMMyy')+RIGHT('0000'+CAST(m.Marsh AS VARCHAR(4)),4) [Barcode],
         count(distinct mr.PINTo) [Dots],
         sum(iif(mr.ReqType=0,1,0)) [kolttn],
         0 [wgpay],
         0 [distpay],
         0 [dotspay],
         0 [ip],
         @sert [vet],
         IIF((not @tipr like '%[абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ]%'),'Область','Город') [tipr],
         m.TimePlan,
         iif(@warranty_count is null,' ',cast(@warranty_count as varchar)) [warranty_count],
         iif(@warrantyGoods_count is null,' ',cast(@warrantyGoods_count as varchar)) [warrantyGoods_count],
         (select count(datnom) from dbo.nc where mhid=@mhid and stip=4) [warranty_count_out],
         iif(d.crID=7,'1','') [way_count],
         iif(@back_count is null,' ',cast(@back_count as varchar)) [back_count]
  FROM [dbo].Marsh m
  inner join NearLogistic.MarshRequests mr on mr.mhid=m.mhid 
  LEFT JOIN [dbo].Vehicle v ON m.V_ID = v.v_id
  LEFT JOIN [dbo].Drivers d ON m.drId = d.drId
  LEFT JOIN [dbo].Drivers s ON m.SpedDrID = s.drId
  WHERE m.mhid=@mhid
  group by d.crid,m.Marsh,CONVERT(VARCHAR,m.nd,104),m.Dist,v.RegNom,v.Model,d.Fio+' '+d.Phone,s.Fio+' '+s.Phone,'12'+format(m.nd,'ddMMyy')+RIGHT('0000'+CAST(m.Marsh AS VARCHAR(4)),4),m.TimePlan
END