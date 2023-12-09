CREATE FUNCTION [db_FarLogistic].BillDate (
)
RETURNS table
AS
return 	select MIN(j.FDate) BillDT, j.NumberWorks, ji.MarshID 
				from db_FarLogistic.dlJorney j
        left join db_FarLogistic.dlJorneyInfo ji on ji.IDReq=j.IDReq
        where not j.NumberWorks is null and not j.FDate is null
        group by ji.MarshID,j.numberworks