CREATE FUNCTION NearLogistic.get_marsh_name (@mhid int)
returns varchar(500)
as
begin
  declare @res varchar(500) =''
  select @res=
         isnull(m.direction+' '+char(13),'')+
         isnull(
         stuff((select N','+iif(mr.reqtype=-2, nearlogistic.get_free_reg_id(mr.reqid,1),r.place)
              from NearLogistic.marshrequests mr 
              join dbo.def d on d.pin=iif(mr.pinFrom>0,mr.pinFrom,mr.pinTO)
              join dbo.regions r on r.reg_id=d.reg_id
              where mr.mhid=m.mhid and mr.reqtype in (0,-2)
              group by iif(mr.reqtype=-2, nearlogistic.get_free_reg_id(mr.reqid,1),r.place),r.priority
              order by r.priority
              for xml path(''), type).value('.','varchar(max)'),1,1,''),
              '<..>')            
  from dbo.marsh m where m.mhid=@mhid
  return ltrim(rtrim(@res))      
end