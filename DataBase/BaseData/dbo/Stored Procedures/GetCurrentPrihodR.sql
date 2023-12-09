CREATE PROCEDURE dbo.GetCurrentPrihodR
AS
select 	A.*, 
				V.Fam, 
				v.PercExpDate
from PrihodReq A 
left join Vendors V on V.Ncod=A.PrihodRVendersID
where a.PrihodRDone=30 and 
			not exists(	select * 
									from PrihodReqDet D 
									where (	select 1 
												  from taracode2 t 
													where t.TaraTag=d.PrihodRDetHitag 
													group by t.TaraTag)<>1  and 
												d.PrihodRID=a.PrihodRID)
			and a.PrihodROpSave= case when cast(a.PrihodRDate as date)=dbo.today() then a.PrihodROpSave else 0 end