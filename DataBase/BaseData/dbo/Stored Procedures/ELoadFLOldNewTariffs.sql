CREATE procedure dbo.ELoadFLOldNewTariffs
@nd1 datetime,
@nd2 datetime,
@isMorozko bit=0
AS
begin
  select x.*,
         x.[УправленческийТариф]-x.[НалоговыйТариф] [РазницаТарифов]
  from (select b.MarshID [КодМаршрута],
               b.WorkID [КодГруппы],
               convert(varchar,b.GivenDate,104) [Дата],
               cast(b.RealBillID as int) [Счет1С],
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
								+isnull(v1.RegNom,'<нет>') [НаименованиеРаботы],
               b.ForPay [НалоговыйТариф],
               case when t.isFix=1 then b.ForPay else 
                    case when t.KM+t.delta<t.minKM then t.NewCost else (t.KM+t.delta)*t.PalKMCost*2*t.PalCount+(t.DotsCount-2)*t.dotCost end end+
                    isnull((select sum(e.Cost) from db_FarLogistic.dlMarshExpence e where e.MarshID=t.MarshID and e.WorkID=t.WorkID),0) [УправленческийТариф],
               t.DotsCount [Точек],
               (t.KM+t.delta) [Километраж],
               case when t.isFix=1 then 0.0 else t.PalCount end [Паллет],
               case when t.isFix=1 then 0.0 else t.PalKMCost*1.0 end [НалоговыйКМПалМесто],
               case when t.isFix=1 then 0.0 else t.PalKMCost*2*1.0 end [УправленческийКМПалМесто],
               case when t.isFix=1 then 0.0 else (t.DotsCount-2)*t.dotCost end [Доплата за точки]
        from db_FarLogistic.dlGroupBill b
        join db_FarLogistic.dlTmpMarshCost t on b.MarshID=t.MarshID and b.WorkID=t.WorkID
        join db_FarLogistic.StrForBill(0) s on s.MarshID=b.MarshID and s.WorkID=b.WorkID
        left join db_FarLogistic.dlMarsh m on m.dlMarshID=b.MarshID 
 				left join db_FarLogistic.BillDate() bd on bd.NumberWorks=b.WorkID and bd.marshid=b.MarshID 
 				left join db_FarLogistic.dlDrivers p on p.ID=m.IDdlDrivers 
 				left join db_FarLogistic.dlVehicles v on v.dlVehiclesID=m.IDdlVehicles 
 				left join db_FarLogistic.dlVehicles v1 on v1.dlVehiclesID=m.idTrailer  
        where convert(varchar,b.GivenDate,104) >= @nd1 
        			and convert(varchar,b.GivenDate,104) <= @nd2
              and (((b.CasherID=16256)and(@isMorozko=1))or((b.CasherID<>16256)and(@isMorozko=0)))
              --and cast(b.RealBillID as int)>=1583
              ) x
   order by x.[Счет1С]
 end