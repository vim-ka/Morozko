CREATE FUNCTION [db_FarLogistic].GetReqMarshStr (
)
RETURNS table
AS
return
select 	ji.IDReq, 
				case when js.IDdlDelivPoint is null then '<Точка не задана>' else ps.PointAlies end ss,
        case when je.IDdlDelivPoint is null then '<Точка не задана>' else pe.PointAlies end se,
				js.PDate, 
        js.FDate
from db_FarLogistic.dlJorneyInfo ji 
left join db_FarLogistic.dlJorney js on js.IDReq = ji.idreq and js.IDdlPointAction = 2 
left join db_FarLogistic.dlDelivPoint ps on ps.dlDelivPointID = js.IDdlDelivPoint
left join db_FarLogistic.dlJorney je on je.IDReq = ji.idreq and je.IDdlPointAction = 5 
left join db_FarLogistic.dlDelivPoint pe on pe.dlDelivPointID = je.IDdlDelivPoint
where ji.JorneyTypeID in (1,2)
union 
select ji.IDReq, ps.PointAlies, '', js.PDate, js.FDate
from db_FarLogistic.dlJorneyInfo ji 
left join db_FarLogistic.dlJorney js on js.IDReq = ji.idreq and js.IDdlPointAction = 7
left join db_FarLogistic.dlDelivPoint ps on ps.dlDelivPointID = js.IDdlDelivPoint
where ji.JorneyTypeID in (3,4)