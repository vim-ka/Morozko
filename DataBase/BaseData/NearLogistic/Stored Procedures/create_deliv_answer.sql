CREATE PROCEDURE NearLogistic.create_deliv_answer @cgid int
AS
BEGIN
  
  SELECT 
    f.mrfID,
    f.DocDate as Date,
    iif(isnull(m.mhid,0)=0,'Нет','Да') as Delivered,
    iif(isnull(m.mhid,0)=0,'нет доставки','') as Reason,
    f.DocNumber as Number,
    f.extcode as ID,  
    f.mhID as RTID,
    m.marsh as RTNUMBER,
    m.nd as RTDATE,
    iif(m.TimePlan='',m.TimeStart,m.TimePlan) as RTTIME, 
    isnull(m.Direction,'')+' '+ NearLogistic.GetMarshRegString(m.mhID) as RTNAME,
    d.DrID,
    d.fio as DrName,
    v.v_id as CRID,
    v.[Model] as CRNAME,
    v.RegNom as CRNUMBER,
    e.drId as EXPID,
    e.fio as EXPNAME,
    d.DriverDoc as DRVDOC,
    f.pin    
  FROM 
    NearLogistic.MarshRequests_free f left join dbo.Marsh m on f.mhid=m.mhid 
                                      left join dbo.Vehicle v on m.v_id=v.v_id
                                      left join dbo.Drivers d on m.drID=d.drID 
                                      left join dbo.Drivers e on m.SpeddrID=e.drID 
                                      join NearLogistic.marshrequests_cashers c on f.pin=c.casher_id
  where c.cgid=@cgid and (f.dt_create>=dbo.today() or f.nd=DATEADD(DAY,1, dbo.today()))
   /*f.pin in (2,3,4) and*/     
   --  where f.pin in (18) and (f.dt_create>=dbo.today()-1 or f.nd=DATEADD(DAY,1, dbo.today()))
END