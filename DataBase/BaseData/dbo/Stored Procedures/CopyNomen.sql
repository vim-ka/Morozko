CREATE PROCEDURE dbo.CopyNomen
@FromHitag int
AS
declare @NewHitag int

set @NewHitag=(	select top 1 nom.hh  
								from (select 	case when ROW_NUMBER() OVER(ORDER BY hitag) in (select hitag from Nomen) 
																	 then 0
																	 else  ROW_NUMBER() OVER(ORDER BY hitag)
															end hh
											from Nomen) nom
								where nom.hh>0)
if @NewHitag=0 set @NewHitag=(select max(hitag)+1 from Nomen);
			  
insert into Nomen(hitag,name,inactive,nds,price,cost,minp,mpu,ngrp,fname,emk,egrp,
  								sert_id,prior,barcode,barcodeMinP,MinW,Netto,Brutto,MinEXTRA,
  								Closed,OnlyMinP,MeasID,Weight_b,disab,NCID,
  								AddTag,KZarp,STM,krep,LastSkladID,LastProducerID,LastCountryID,
  								SafeCust,NgrpOld,ShelfLifeAdd,ShelfLife,Op,date,DateCreate,price_old, UnID, flgFract) 
select 	@NewHitag,name,inactive,nds,price,cost,minp,mpu,ngrp,fname,emk,egrp,sert_id,prior,
  			'','',MinW,Netto,Brutto,MinEXTRA,Closed,OnlyMinP,MeasID,Weight_b,
  			disab,NCID,AddTag,KZarp,STM,krep,LastSkladID,LastProducerID,
  			LastCountryID,SafeCust,NgrpOld,ShelfLifeAdd,ShelfLife,Op,date,DateCreate,price_old, UnID, flgFract
from Nomen
where hitag=@FromHitag

select @NewHitag [NewHitag]