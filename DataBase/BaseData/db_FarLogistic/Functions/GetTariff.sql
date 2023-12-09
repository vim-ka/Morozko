CREATE FUNCTION db_FarLogistic.GetTariff (@MarshID int, @WorkID int)
RETURNS @tbl TABLE (flgFix bit, tCost money, minCost money, minKM int, dotCost money)
AS
BEGIN
insert into @tbl
select x.[flg],x.[c],x.[mc],x.[mk],x.[dc]
from (
	select 	row_number() over(order by e.DateStart desc) [n],
					case when exists(select * 
													from db_FarLogistic.dlJorneyInfo ji 
													join db_FarLogistic.dlJorney j on j.idreq=ji.idreq 
													where ji.MarshID=@MarshID 
																and j.NumberWorks=@WorkID
																and ji.Cost>0) then cast(1 as bit) else cast(0 as bit) end [flg],
					case when exists(select * 
													from db_FarLogistic.dlJorneyInfo ji 
													join db_FarLogistic.dlJorney j on j.idreq=ji.idreq 
													where ji.MarshID=@MarshID 
																and j.NumberWorks=@WorkID
																and ji.Cost>0) then (	select top 1 ji.Cost 
																											from db_FarLogistic.dlJorneyInfo ji 
																											join db_FarLogistic.dlJorney j on j.idreq=ji.idreq 
																											where ji.MarshID=@MarshID 
																														and j.NumberWorks=@WorkID
																														and ji.Cost>0)
					else e.KMPalCost end [C], 
					e.MinCost [mc], 
					e.MinRaceKM [mk], 
					e.DotCost [dc]
	from db_FarLogistic.dlExpence e
	where e.IDVehTYpe=(	select v.dlVehTypeID
											from db_FarLogistic.dlVehicles v 
											join db_FarLogistic.dlMarsh m on v.dlVehiclesID=m.IDdlVehicles
											where m.dlMarshID=@MarshID) 
				and e.DateStart<=(select top 1 m.dt_end_fact from db_FarLogistic.dlMarsh m where m.dlMarshID=@MarshID) 
) x
where x.[n]=1	

return
END