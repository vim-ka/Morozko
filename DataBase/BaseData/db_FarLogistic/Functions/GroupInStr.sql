CREATE FUNCTION [db_FarLogistic].[GroupInStr] (
)
RETURNS table 
AS
return 
select g.MarshID, g.WorkID,
	cast(STUFF((select N'-'+isnull(p.City,'*ГОРОД*')+','+isnull(p.Street,'*УЛИЦА*')+','+isnull(p.House,'*ДОМ*')
	from db_FarLogistic.dlGroupBill b
	left join db_FarLogistic.dlJorneyInfo ji on ji.MarshID=b.MarshID
	left join db_FarLogistic.dlJorney j on j.IDReq=ji.IDReq and j.NumberWorks=b.WorkID
	left join db_FarLogistic.dlDelivPoint p on p.dlDelivPointID=j.IDdlDelivPoint
	where j.NumbForRace>0 and g.MarshID=b.MarshID and g.WorkID=b.WorkID and j.isHide=0
	order by j.NumbForRace 
	for xml path(''), type).value('.','varchar(max)'),1,1,'') as varchar(500)) Routes
from db_FarLogistic.dlGroupBill g