CREATE FUNCTION [db_FarLogistic].GetReqWeight (
)
RETURNS table
AS
return
select j.IDReq, sum(isnull(j.FWeight,0)) SWeight, sum(isnull(j.FCount,0)) scount, sum(isnull(j.PWeight,0)) PWeight, sum(isnull(j.PCount,0)) PCount
from db_FarLogistic.dlJorney j
where j.IDdlPointAction in (2,3)
group by j.IDReq
union 
select j.IDReq, 0, 0, 0, 0
from db_FarLogistic.dlJorney j
where j.IDdlPointAction=7