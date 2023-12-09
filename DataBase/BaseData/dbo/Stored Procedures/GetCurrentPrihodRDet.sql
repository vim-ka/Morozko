CREATE PROCEDURE dbo.GetCurrentPrihodRDet
@PrihodID int =-1
AS
select  d.*,
				n.[name],
				n.ShelfLife,
				n.ShelfLifeAdd,
				-1 id,--t.ID,
				case when (n.ShelfLife>0) and (PrihodRDetDate is not null) then
				case when  DATEDIFF(day,PrihodRDetDate,getdate())*100/n.ShelfLife<v.PercExpDate then 'разблокировка' else 'д.б. разблокировано'  end 
				else 'неполн. данные' end locktext
from PrihodReqDet D 
left join Nomen n on D.PrihodRDetHitag=n.hitag 
left join PrihodReq A on D.PrihodRID=A.PrihodRID
left join Vendors V on V.Ncod=A.PrihodRVendersID
--left join tdvi t on t.HITAG=d.PrihodRDetHitag and d.PrihodRDetNCom=t.NCOM
where  a.PrihodRDone=30  
			 and d.PrihodRDetCloneMain=1
			 and d.PrihodRID=case when @PrihodID=-1 then d.PrihodRID else @PrihodID end
			 --and not t.sklad in (88,92)
			 and not d.PrihodRDetHitag in (5659,2296,90858,95007,15028)
			 --and exists(select t.hitag from tdvi t where t.hitag=d.PrihodRDetHitag and t.ncom=d.PrihodRDetNCom and not t.sklad in (88,92))
			 and not exists(select * from gr where aginvis=1 and gr.ngrp=n.ngrp)
order by D.PrihodRID, n.[name]