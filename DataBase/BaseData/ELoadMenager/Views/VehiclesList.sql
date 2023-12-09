create view ELoadMenager.VehiclesList
as
select top 1000 v.v_id [id], iif(v.v_id=0,'Авто без изменений',iif(v.crid=7,'[ТДМ] ','')+v.model+' '+v.regnom) [list] 
from dbo.vehicle v 
where v.closed=0 and v.vtip=0
order by iif(v.v_id=0,-1,iif(v.crid=7,0,1)),v.model+' '+v.regnom