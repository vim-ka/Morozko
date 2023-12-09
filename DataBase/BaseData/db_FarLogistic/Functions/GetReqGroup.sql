CREATE FUNCTION [db_FarLogistic].GetReqGroup (
)
RETURNS table
AS
return
select 	j.IDReq,
				case when j.IDReq < 0 then -1 else 
				case when (p.IDReqGroup is NULL)or(not p.IDReqGroup in (select g.IDReqGroup from db_FarLogistic.dlReqGroup g)) then 0 
        else p.IDReqGroup end end idgroup
from db_FarLogistic.dlJorney j
left join db_FarLogistic.dlDelivPoint p on p.dlDelivPointID = j.IDdlDelivPoint
where j.IDdlPointAction = 2
union 
select 	j.IDReq,
				case when j.IDReq < 0 then -1 else 
				case when (p.IDReqGroup is NULL)or(not p.IDReqGroup in (select g.IDReqGroup from db_FarLogistic.dlReqGroup g)) then 0 
        else p.IDReqGroup end end idgroup
from db_FarLogistic.dlJorney j
left join db_FarLogistic.dlDelivPoint p on p.dlDelivPointID = j.IDdlDelivPoint
where j.IDdlPointAction = 7