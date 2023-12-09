CREATE FUNCTION [db_FarLogistic].[StrForBill] ( @pal bit =0)
RETURNS table 
AS
return 
select g.MarshID, g.WorkID,
	STUFF((select N'-'+isnull(p.City,'*Город*')+case when @pal=0 then '' 
																									 else case when j.IDdlPointAction in (2,3) then '{п:' 
																									 					 when j.IDdlPointAction in (4,5) then '{р:'
																														 ELSE '{' End +cast(j.FCount as varchar)+'}' end
	from db_FarLogistic.dlGroupBill b
	left join db_FarLogistic.dlJorneyInfo ji on ji.MarshID=b.MarshID
	left join db_FarLogistic.dlJorney j on j.IDReq=ji.IDReq and j.NumberWorks=b.WorkID
	left join db_FarLogistic.dlDelivPoint p on p.dlDelivPointID=j.IDdlDelivPoint
	where j.NumbForRace>0 and g.MarshID=b.MarshID and g.WorkID=b.WorkID and j.isHide=case when @pal=1 then j.isHide else 0 end
	order by j.NumbForRace 
	for xml path(''), type).value('.','varchar(max)'),1,1,'') Routes,
	STUFF((select N','+isnull(cast(ji.IDReq as varchar),'0')
	from db_FarLogistic.dlGroupBill b
	left join db_FarLogistic.dlJorneyInfo ji on ji.MarshID=b.MarshID
	where g.MarshID=b.MarshID and g.WorkID=b.WorkID
	order by ji.IDReq 
	for xml path(''), type).value('.','varchar(max)'),1,1,'') Reqs
from db_FarLogistic.dlGroupBill g