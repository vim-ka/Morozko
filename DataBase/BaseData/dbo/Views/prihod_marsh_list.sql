CREATE VIEW dbo.prihod_marsh_list
AS
select 0 [id], 'Бесплатно' [list]
union 
select -1, 'Оплата поставщику'
union 
select m.dlMarshID, '['+convert(varchar,isnull(dt_end_fact,dt_end_plan),104)+']['+d.Surname
									 --+']['+v.Model+' '+rtrim(v.RegNom)
                   +']['+dbo.get_vendors_marsh(m.dlMarshID)+']'
from db_FarLogistic.dlMarsh m
join db_FarLogistic.dlDrivers d on d.id=m.IDdlDrivers
join db_FarLogistic.dlVehicles v on v.dlVehiclesID=m.IDdlVehicles
where isnull(dt_end_fact,dt_end_plan) >= convert(varchar,dateadd(week,-2,getdate()),104)		
			and m.IDdlMarshStatus in (2,3,4)
order by 1 desc offset 0 rows