CREATE PROCEDURE db_FarLogistic.GetMarsh
@isArch bit=0
AS
if @isArch=0
select 	m.dlMarshID [MarshID],
				m.IDdlMarshStatus [StatusID],
				m.dt_beg_fact [dt],
				m.IDdlDrivers [DriveID],
				m.IDdlVehicles [VehID],
				m.idTrailer [TrailerID],
				isnull(ms.Race,'<..>') [Race],
				cast(isnull(a.plCount,0) as varchar)+'/'+cast(isnull(a.pdCount,0) as varchar) [pPAL],
				cast(isnull(a.plWeight,0) as varchar)+'/'+cast(isnull(a.pdWeight,0) as varchar) [pWEI],
				cast(isnull(a.flCount,0) as varchar)+'/'+cast(isnull(a.fdCount,0) as varchar) [fPAL],
				cast(isnull(a.flWeight,0) as varchar)+'/'+cast(isnull(a.fdWeight,0) as varchar) [fWEI]
from db_FarLogistic.dlMarsh m
left join db_FarLogistic.MarshInStrings() ms on ms.MarshID=m.dlMarshID
left join (	select 	ji.MarshID,
										sum(j.PCount) plCount,
										sum(j.PWeight) plWeight,
										sum(j.FCount) flCount,
										sum(j.FWeight) flWeight,
										sum(j.PCount) pdCount,
										sum(j.PWeight) pdWeight,
										sum(j.FCount) fdCount,
										sum(j.FWeight) fdWeight
						from db_FarLogistic.dlJorneyInfo ji 
						left join db_FarLogistic.dlJorney j on ji.IDReq=j.IDReq and j.IDdlPointAction in (2,3,7)
						left join db_FarLogistic.dlJorney jj on ji.IDReq=jj.IDReq and jj.IDdlPointAction in (4,5,8)
						group by ji.MarshID
						) a on a.MarshID=m.dlMarshID
where m.IDdlMarshStatus in (1,2,3) --or m.dlMarshID=1703057
order by m.IDdlMarshStatus desc,m.dt_beg_fact desc
else
select 	m.dlMarshID [MarshID],
				m.IDdlMarshStatus [StatusID],
				m.dt_beg_fact [dt],
				m.IDdlDrivers [DriveID],
				m.IDdlVehicles [VehID],
				m.idTrailer [TrailerID],
				isnull(ms.Race,'<..>') [Race],
				cast(isnull(a.plCount,0) as varchar)+'/'+cast(isnull(a.pdCount,0) as varchar) [pPAL],
				cast(isnull(a.plWeight,0) as varchar)+'/'+cast(isnull(a.pdWeight,0) as varchar) [pWEI],
				cast(isnull(a.flCount,0) as varchar)+'/'+cast(isnull(a.fdCount,0) as varchar) [fPAL],
				cast(isnull(a.flWeight,0) as varchar)+'/'+cast(isnull(a.fdWeight,0) as varchar) [fWEI]
from db_FarLogistic.dlMarsh m
left join db_FarLogistic.MarshInStrings() ms on ms.MarshID=m.dlMarshID
left join (	select 	ji.MarshID,
										sum(j.PCount) plCount,
										sum(j.PWeight) plWeight,
										sum(j.FCount) flCount,
										sum(j.FWeight) flWeight,
										sum(j.PCount) pdCount,
										sum(j.PWeight) pdWeight,
										sum(j.FCount) fdCount,
										sum(j.FWeight) fdWeight
						from db_FarLogistic.dlJorneyInfo ji 
						left join db_FarLogistic.dlJorney j on ji.IDReq=j.IDReq and j.IDdlPointAction in (2,3,7)
						left join db_FarLogistic.dlJorney jj on ji.IDReq=jj.IDReq and jj.IDdlPointAction in (4,5,8)
						group by ji.MarshID
						) a on a.MarshID=m.dlMarshID
order by m.IDdlMarshStatus desc,m.dt_beg_fact desc