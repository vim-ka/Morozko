CREATE PROCEDURE dbo.GetCurrentNomenList
AS
select 	t.ID,
				cast(n.hitag as int) [hitag],
				n.name,
				IIF(n.flgWeight=1,t.WEIGHT,(t.MORN-t.SELL+t.ISPRAV-t.REMOV)*n.Netto) [WEIGHT],
				t.DATER,
				t.SROKH,
				datediff(day, t.DATER, t.SROKH) [sr], --  +1
				t.DATEPOST,
				t.LOCKED,
				t.LockID,
				d.fam [ncod],
				t.ProducerID,
				c.ProducerName [NCOUNTRY],
        t.ProducerCodeId,
				t.SERT_ID,
				t.MORN-t.SELL+t.ISPRAV-t.REMOV [ost],
        t.STARTID          
from tdVi t
left join nomen n on n.hitag=t.hitag
left join vendors d on d.ncod=t.ncod
left join Producer c on c.ProducerID=t.ProducerID
--LEFT JOIN ProducerCode ON c.ProducerID = ProducerCode.ProducerId
LEFT JOIN ProducerCode ON t.ProducerCodeId = ProducerCode.ProducerCodeId
where n.ngrp in (select x.ngrp from gr x where x.AgInvis=0)
			and t.MORN-t.SELL+t.ISPRAV-t.REMOV>0
order by t.DATEPOST