CREATE FUNCTION NearLogistic.GetMarshRegString (@mhID int)
RETURNS varchar(500)
AS
begin
declare @direction varchar(500)

/*set @direction=left (
    isnull(
       stuff((select N','+r.Place
       from NearLogistic.MarshRequests mr 
            inner join def d on d.pin=iif(mr.pinFrom>0,mr.pinFrom,mr.pinTO)
            inner join dbo.Regions r on r.Reg_ID=d.Reg_ID
            where mr.mhid=@mhid and mr.ReqType<>4
            group by r.place,r.Priority
            order by r.Priority
            for xml path(''), type).value('.','varchar(max)'),1,1,''),
            '<..>'),500)
*/           
            
set @direction=left(             
  (select isnull(
       stuff((select N','+iif(mr.reqtype=-2, nearlogistic.get_free_reg_id(mr.reqid,1),r.Place)
       from NearLogistic.MarshRequests mr 
            inner join def d on d.pin=iif(mr.pinFrom>0,mr.pinFrom,mr.pinTO)
            inner join dbo.Regions r on r.Reg_ID=d.Reg_ID
            where mr.mhid=m.mhid and mr.ReqType<>4
            group by iif(mr.reqtype=-2, nearlogistic.get_free_reg_id(mr.reqid,1),r.Place),r.Priority
            order by r.Priority
            for xml path(''), type).value('.','varchar(max)'),1,1,''),
            '<..>')
            +isnull(' '+m.driver,'')
  from dbo.marsh m
  where m.mhID=@mhID)
 ,500)            
            
            
            
return @direction
end