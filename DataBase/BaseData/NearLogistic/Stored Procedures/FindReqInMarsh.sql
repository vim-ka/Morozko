CREATE PROCEDURE NearLogistic.FindReqInMarsh
@typeID int,
@reqID int,
@nd datetime,
@pin int
AS
BEGIN
declare @datnom Bigint 

if len(cast(@reqid as varchar))<=4 and @reqid<>0
 set @datnom=dbo.InDatNom(@reqID,@nd)
else
 set @datnom=0
  
select mr.mrID,
    mr.mhID,
       mr.ReqID,
       m.Marsh,
       m.ND,
       ms.msName,
       isnull(m.Direction,'')+isnull(rs.RegName,'') [direction],
       rt.ReqName,
       mr.DelivCancel,
       mr.ReqType
from NearLogistic.MarshRequests mr
left join dbo.marsh m on m.mhid=mr.mhid
left join NearLogistic.MarshStatus ms on ms.msID=m.MStatus
inner join NearLogistic.RequestsType rt on rt.ReqType=mr.ReqType
left join NearLogistic.GetRegsString(@nd) rs on rs.mhid=m.mhid
where mr.ReqType=iif(@typeID=-1,mr.ReqType,@typeID)
   and mr.ReqID=iif(@reqID=0,mr.ReqID,iif(mr.ReqType=0,@datnom,@reqID))
      and mr.PINTo=iif(@pin=0,mr.PINTo,@pin)
      --and convert(varchar,mr.dt,104)=@nd
END