CREATE PROCEDURE db_FarLogistic.GetInfoForRaces
@nd1 datetime,
@nd2 datetime,
@c bit,
@id int
AS
BEGIN
select 	m.dlMarshID [КодМаршрута],
				m.dt_beg_fact [ДатаВыезда],
				d.Surname+' '+d.Firstname+' '+d.Middlename [ФИОВодителя],
				v.Model+' '+v.RegNom [Авто],
				b.RealBillID [№Счета],
				f.brName [Контрагент],
				s.Routes [Маршрут],
				b.ForPay [Сумма]
from db_FarLogistic.dlGroupBill b
left join db_FarLogistic.dlMarsh m on m.dlMarshID=b.MarshID
left join db_FarLogistic.StrForBill(1) s on s.MarshID=m.dlMarshID and s.WorkID=b.WorkID
left join db_FarLogistic.dlDrivers d on d.ID=m.IDdlDrivers
left join db_FarLogistic.dlVehicles v on v.dlVehiclesID=m.IDdlVehicles
left join def f on f.pin=b.CasherID
where b.GivenDate between @nd1 and @nd2 
			and m.IDdlDrivers=case when @c=0 then @id else m.IDdlDrivers end
			and m.IDdlVehicles=case when @c=1 then @id else m.IDdlVehicles end
order by 1,5
END