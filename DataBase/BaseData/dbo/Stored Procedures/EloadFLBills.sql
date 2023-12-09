CREATE PROCEDURE dbo.EloadFLBills
@dt1 datetime,
@dt2 datetime
AS
BEGIN
  select b.RealBillID [КодСчета1С],
  			 b.dlGroupBillID [КодСчетаУправленка],
         d.nal [Наличные],
         d.brName [НаименованиеКлиента],
         b.MarshID [КодМаршрута],
         b.GivenDate [ДатаВыствления],
         bd.BillDT [Дата1С],
         t.km [ПробегБезПоправки],
         t.km+t.delta [ПробегСПоправкой],
         t.PalCount [КоличествоПаллет],
         t.palWeight [Вес],
         t.Cost [СтоимостьБезПоправки],
         isnull((select sum(e.Cost) from db_FarLogistic.dlMarshExpence e where e.MarshID=t.MarshID and e.WorkID=t.WorkID),0) [РасходыКМаршруту],
         b.ForPay [ОкончательнаяСтоимомть]
  from db_FarLogistic.dlGroupBill b
  left join db_FarLogistic.dlTmpMarshCost t on b.MarshID=t.MarshID and b.WorkID=t.WorkID
  inner join db_FarLogistic.dlDef d on d.id=b.CasherID
  inner join db_FarLogistic.BillDate() bd on bd.NumberWorks=b.WorkID and bd.marshid=b.MarshID
  where b.GivenDate between @dt1 and @dt2
  order by cast(b.RealBillID as int)
END