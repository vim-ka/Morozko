CREATE FUNCTION [db_FarLogistic].MarshInStrings (
)
RETURNS table 
AS
return 
select 	m.dlMarshID MarshID, 
				cast(stuff(
             (select N'->'+isnull(p.PointAlies,'*Псевдоним не задан*')
              from db_FarLogistic.dlJorneyInfo ji 
              left join db_FarLogistic.dlJorney j on j.IDReq = ji.IDReq 
              left join db_FarLogistic.dlDelivPoint p on p.dlDelivPointID = j.IDdlDelivPoint              
              where ji.MarshID = m.dlMarshID and j.IDdlPointAction in (2,3,4,5,7) and j.NumbForRace>0 and j.isHide=0
              order by j.NumbForRace 
              for xml path(''), type).value('.','varchar(max)'),1,2,''  
        			) as varchar(500)) Race
from db_FarLogistic.dlMarsh m
group by m.dlMarshID