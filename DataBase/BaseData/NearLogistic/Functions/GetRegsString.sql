CREATE FUNCTION NearLogistic.GetRegsString (@nd datetime)
RETURNS table
AS
return
select m.mhid,
			 isnull(
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
            [RegName],
       isnull(
       stuff((select N','+iif(mr.reqtype=-2, nearlogistic.get_free_reg_id(mr.reqid,0),r.reg_id)
			 			from NearLogistic.MarshRequests mr 
            inner join def d on d.pin=iif(mr.pinFrom>0,mr.pinFrom,mr.pinTO)
            inner join dbo.Regions r on r.Reg_ID=d.Reg_ID
            where mr.mhid=m.mhid and mr.ReqType<>4
            group by iif(mr.reqtype=-2, nearlogistic.get_free_reg_id(mr.reqid,0),r.reg_id),r.Priority
            order by r.Priority
            for xml path(''), type).value('.','varchar(max)'),1,1,''),
            '<..>') [Reg_ID],
       isnull(
       stuff((select N','+s.sregName
			 			from NearLogistic.MarshRequests mr 
            inner join def d on d.pin=iif(mr.pinFrom>0,mr.pinFrom,mr.pinTO)
            inner join dbo.Regions r on r.Reg_ID=d.Reg_ID
            left join warehouse.skladreg s on s.sregionID=r.sregionID
            where mr.mhid=m.mhid and mr.ReqType<>4
            group by s.sregName
            order by s.sregName
            for xml path(''), type).value('.','varchar(max)'),1,1,''),
            '<..>') [sReg_ID]
from dbo.marsh m
where m.nd=@nd
			and not m.Marsh in (0,99)