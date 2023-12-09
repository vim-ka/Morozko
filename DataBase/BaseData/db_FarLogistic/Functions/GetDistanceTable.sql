CREATE FUNCTION db_FarLogistic.GetDistanceTable (@MarshID int, @WorkID int)
RETURNS @tbl table (n int, pID1 int, pID2 int, Distance int)
AS
BEGIN
declare @max int

select @max=max(j.NumbForRace)
from db_FarLogistic.dlJorney j
join db_FarLogistic.dlJorneyInfo ji on j.IDReq=ji.IDReq
where ji.MarshID=@MarshID
			and j.NumberWorks=(case when @WorkID=0 then j.NumberWorks else @WorkID end)
			and j.NumbForRace>0

insert into @tbl
select 	z.[n],
				z.[pID1],
				z.[pID2],
				db_FarLogistic.GetDistancePair(z.[pID1],z.[pID2]) [Distance]
					 
from (
select 	x.[n],
				x.[numb], 
				x.[pID1], 
				case when x.[numb]=@max then (case when @WorkID=0 then 8 else x.[pID1] end) 
				else (	select y.[pID]
								from (select	row_number() over(order by j.NumbForRace) [n],
															j.IDdlDelivPoint [pID]
											from db_FarLogistic.dlJorney j
											join db_FarLogistic.dlJorneyInfo ji on j.IDReq=ji.IDReq
											where ji.MarshID=@MarshID
														and j.NumbForRace>0
														and j.NumberWorks=(case when @WorkID=0 then j.NumberWorks else @WorkID end)
											union all
											select 0,8) y
								where y.[n]=x.[n]+1 ) 
				end [pID2] 
from (select 	row_number() over(order by j.NumbForRace) [N],
							j.NumbForRace [Numb],
							j.IDdlDelivPoint [pID1]
			from db_FarLogistic.dlJorney j
			join db_FarLogistic.dlJorneyInfo ji on j.IDReq=ji.IDReq
			where ji.MarshID=@MarshID
						and j.NumbForRace>0
						and j.NumberWorks=(case when @WorkID=0 then j.NumberWorks else @WorkID end)
			union all
			select 0,0,8) x
) z
where n<> (case when @WorkID=0 then -1 else 0 end)
order by 1

return
END