CREATE PROCEDURE NearLogistic.printmarshlist_new  
@mhid int
as
begin

select *
into #tmpReqInfo
from  NearLogistic.GetReqInfo(@mhid)

select iif(c.pinfrom<>0,c.PINFrom,c.pinto) [b_id],
       iif(c.reqtype<>4,a.gpname,sb.BrName) [fam],
	     iif(c.reqtype<>4,a.reg_id,'') [reg_id],
       iif(c.reqtype<>4,iif(isnull(a.dstaddr,'')<>'', a.dstaddr, a.gpAddr),sb.Address) [gpaddr],
       iif(c.reqtype<>4,a.gpphone,sb.Phone) [gpphone],
       c.kolbox_ [kolbox],
       iif(c.reqtype=0, isnull((select TOP 1 '  '+nc.RemarkOp from nc where nc.datnom=c.reqid), ''), '') [remop],
       --'' [remop],
       --c.reqremark 
       iif(c.reqtype=0,nearlogistic.get_naklsremark(@mhid,c.pinto),c.reqremark) [rem],
       c.cost_ [duty],
       iif(c.reqtype<>4,a.tmpost,'') [tmpost],
       iif(c.reqtype<>4,a.posx,sb.PosX) [posx],
       iif(c.reqtype<>4,a.posy,sb.PosY) [posy],
       0 [tara],
       c.reqid [dnom],
       iif(c.reqtype=0,1,0) [countnak],
       0 [tarabkol],
       0 [skgname],
       iif(c.reqtype=0,isnull((select 1 from nc where nc.datnom=c.reqid and nc.sertifdoc & 223<>0),0),0) [sertif],
       iif(a.tmwork='K','Вермя работы - круглосуточно',iif(a.tmWork<>'','Время работы - '+a.tmWork,''))+iif(a.tmDin<>'','; перерыв - '+a.tmDin,'') [tmwork],
       iif(c.reqtype<>4,a.tmdin,'') [tmdin],
       p.phone [agphone],
       '' as [timearrival],
       c.reqorder as marsh2,
       0 [sert],
       case when isnull(a.wostamp,0)<>0 then 'без печати' else 'печать ОБЯЗАТЕЛЬНА' end [wostamp],
       case when a.ndcoord is null then '' else 'сверены' end [coordsver],
       iif(c.reqtype<>4,a.fmt,0) [fmt],
       0 [ourid],       
       ri.listnaks,
       iif(c.reqtype=0,(select count(distinct pl.datnom) from dbo.dover2printlog pl where pl.datnom=c.reqid),0) [dover],
       c.ReqType,
       rt.ReqName,
       IIF(nc.B_Id2>0, 'ПЛАТЕЛЬЩИК: '+CAST(nc.B_Id AS VARCHAR), '') +' ' + IIF(nc.B_Id2>0, d.gpName, '') [casherfam]
       
from nearlogistic.marshrequests c 
join NearLogistic.RequestsType rt on rt.ReqType=c.ReqType
left join #tmpReqInfo ri on ri.ReqID=c.ReqID
left join dbo.def a on a.pin=iif(c.pinfrom<>0,c.PINFrom,c.pinto) and c.reqtype<>4
left join dbo.SertifBranch sb on sb.BrNo=c.pinTo
left join dbo.agentlist l on c.ag_id=l.ag_id
left join dbo.person p on l.p_id=p.p_id
LEFT JOIN nc ON nc.DatNom = c.ReqID
LEFT JOIN def d ON nc.B_Id = d.pin
where c.mhid=@mhid and c.reqtype<>-2

union all

select p.point_id [b_id],
       p.point_name [fam],
	     p.reg_id [reg_id],
      NearLogistic.get_free_adress_string(c.reqid,0) [gpaddr],
       mrf.contact [gpphone],
       mrf.kolbox [kolbox],
       '' [remop],
       c.reqremark [rem],
       mrf.cost [duty],
       p.tmDeliv [tmpost],
       p.posx [posx],
       p.posy [posy],
       0 [tara],
       c.reqid [dnom],
       iif(c.reqtype=0,1,0) [countnak],
       0 [tarabkol],
       0 [skgname],
       0 [sertif],
       '' [tmwork],
       '' [tmdin],
       '' [agphone],
       '' [timearrival],
       c.reqorder as marsh2,
       0 [sert],
       '' [wostamp],
       '' [coordsver],
       0 [fmt],
       0 [ourid],       
       ri.listnaks,
       0 [dover],
       c.ReqType,
       rt.ReqName, ''
from nearlogistic.marshrequests c 
left join #tmpReqInfo ri on ri.ReqID=c.ReqID
join NearLogistic.RequestsType rt on rt.ReqType=c.ReqType
join nearlogistic.marshrequests_free mrf on mrf.mrfID=c.reqid
join NearLogistic.marshrequestsdet d on d.mrfid=mrf.mrfid and d.action_id=6
join nearlogistic.marshrequests_points p on p.point_id=d.point_id
left join NearLogistic.marshrequestsdet d1 on d1.mrfid=mrf.mrfid and d1.action_id=5
left join nearlogistic.marshrequests_points p1 on p1.point_id=d1.point_id
join NearLogistic.marshrequests_cashers s on s.casher_id=mrf.pin
where c.mhid=@mhid and c.reqtype=-2
order by c.reqorder,1

drop table #tmpReqInfo
end