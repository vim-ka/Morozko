CREATE PROCEDURE db_FarLogistic.GetBiilFor1C
@dt1 datetime,
@dt2 datetime
AS
BEGIN				
  select 	b.dlGroupBillID VK , 
 	'Транспортные услуги по перевозке продукции '+
	isnull(s.Routes, '<нет>')+
  ' от '
	+isnull(convert(varchar,bd.BillDT,104),'<нет>')+
	' водитель: '
	+isnull(p.Surname, '<нет>') +' '
	+isnull(p.FirstName, '<нет>') +' '
	+isnull(p.MiddleName, '<нет>')+
  ' автомобиль: '
	+isnull(v.Model, '<нет>')+' '
	+isnull(v.RegNom, '<нет>')+' п\п: '
	+isnull(v1.RegNom,'-') ROUTES, 
 	d.upin CODE_K, 
  convert(varchar,b.GivenDate,104) DAT, 
  convert(varchar,b.GivenDate,108) TIM, 
  b.ForPay SUMM,
	b.DepID,
	s.Reqs
 from db_FarLogistic.dlGroupBill b 
 left join db_FarLogistic.StrForBill(0) s on s.MarshID=b.MarshID and s.WorkID=b.WorkID 
 left join db_FarLogistic.dlMarsh m on m.dlMarshID=b.MarshID 
 left join db_FarLogistic.BillDate() bd on bd.NumberWorks=b.WorkID and bd.marshid=b.MarshID 
 left join db_FarLogistic.dlDrivers p on p.ID=m.IDdlDrivers 
 left join db_FarLogistic.dlVehicles v on v.dlVehiclesID=m.IDdlVehicles 
 left join db_FarLogistic.dlVehicles v1 on v1.dlVehiclesID=m.idTrailer 
 left join def d on d.pin=b.CasherID 
 left join db_FarLogistic.dlDef dd on dd.id=d.pin 
 where 	cast(b.GivenDate as date)>=@dt1 
 				and cast(b.GivenDate as date)<=@dt2  
				and dd.nal=0 
 order by b.GivenDate
				
	update db_FarLogistic.dlGroupBill set UnLoaded=1 
	where cast(GivenDate as date)>=@dt1 
 				and cast(GivenDate as date)<=@dt2
	
END