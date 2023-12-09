CREATE FUNCTION db_FarLogistic.ReqInfo (
)
RETURNS table
AS
return
select 	m.IDReq, 
				cast(isnull(stuff(
             (select N'->'+isnull(p.PointAlies,'*Псевдоним не задан*')
              from db_FarLogistic.dlJorney j 
              left join db_FarLogistic.dlDelivPoint p on p.dlDelivPointID = j.IDdlDelivPoint              
              where j.IDReq = m.IDReq and j.IDdlPointAction in (2,3,4,5,7,8) --and j.NumbForRace>0
              order by j.NumbForRace 
              for xml path(''), type).value('.','varchar(max)'),1,2,''  
        			),'<..>') as varchar(300)) [Race],
				convert(varchar,m.PDate,4) [Date],
				isnull(x.PCOunt,0) [Count],
				isnull(x.PWeight,0) [Weight],
				g.idgroup [Group]
from db_FarLogistic.dlJorney m
left join (	select a.IDReq, 
									sum(a.PCount) [PCount], 
									sum(a.PWeight) [PWeight] 
						from db_FarLogistic.dlJorney a 
						where a.IDdlPointAction in (2,3)
						group by a.IDReq) x on x.IDReq=m.IDReq
left join db_FarLogistic.GetReqGroup() g on g.IDReq=m.IDReq
where m.IDdlPointAction in (2,7)