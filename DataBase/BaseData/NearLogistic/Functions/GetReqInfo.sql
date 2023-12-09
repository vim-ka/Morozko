CREATE FUNCTION NearLogistic.GetReqInfo (@mhID int)
RETURNS table
AS
--BEGIN
return
select mr.ReqID,
       cast('№ '
       			+iif(c.StfNom<>'','<b>'+c.stfNom+'</b><i> (','<b>')
            +cast(dbo.InNnak(mr.ReqID) as varchar)+iif(c.StfNom<>'',')</i>','</b>')
            +' вес:'
            +cast(mr.Weight_ as varchar)+' кг.; '+cast(mr.KolBox_ as varchar)+' мест' as varchar(500))
            +iif(isnull(c.Remark,'')='','',char(10)+c.Remark) [listnaks]
from NearLogistic.MarshRequests mr
left join dbo.nc c on c.datnom=mr.reqid 
where mr.mhid=@mhid
	  and mr.ReqType=0
union all
select mr.ReqID,
       '№'+cast(rt.reqnum as varchar)+' '+rt.comment
from NearLogistic.MarshRequests mr 
inner join dbo.ReqReturn rt on mr.ReqID=rt.reqnum
where mr.mhid=@mhid
	  and mr.ReqType=1
union all
select mr.ReqID,
       '№'+cast(fr.rcmplxid as varchar)
from NearLogistic.MarshRequests mr 
inner join dbo.frizrequest fr on mr.ReqID=fr.rcmplxid
where mr.mhid=@mhid
	  and mr.ReqType=2
union all
select mr.ReqID,
       '№'+cast(mbr.mbrID as varchar)
from NearLogistic.MarshRequests mr 
inner join nearlogistic.moneybackrequest mbr on mr.ReqID=mbr.mbrID
where mr.mhid=@mhid
	  and mr.ReqType=3
union all
select mr.ReqID,
       '№'+cast(ms.Mvk as varchar)
from NearLogistic.MarshRequests mr 
inner join dbo.MarshSertif ms on mr.ReqID=ms.Mvk
where mr.mhid=@mhid
	  and mr.ReqType=4
union all
select mr.reqid,
			 'Забрать товар'
from NearLogistic.MarshRequests mr 
inner join dbo.orders o on o.ordid=mr.reqid
where mr.mhid=@mhid
			and mr.reqtype=5    
union all
select mr.reqid,
			 isnull('№'+mrf.DocNumber+' от '+format(mrf.DocDate,'dd.MM.yy'),cast(mrf.mrfID as varchar))
       --mrf.remark
       --nearLogistic.get_free_adress_string(mrf.mrfID,6)
from NearLogistic.MarshRequests mr 
join NearLogistic.MarshRequests_free mrf on mrf.mrfID=mr.reqid
where mr.mhid=@mhid
			and mr.reqtype=-2  
--END