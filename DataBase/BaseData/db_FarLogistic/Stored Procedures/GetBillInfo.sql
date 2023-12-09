CREATE PROCEDURE db_FarLogistic.GetBillInfo
@dt1 datetime,
@dt2 datetime
AS
BEGIN
	--Для Кати
	
  select d.upin 			[upin],
  			 d.brName,
  			 b.ForPay 		[cost],
         t.KM+t.delta [distance],
         b.DepID 			[dep],
         de.DName,
         14 [our_id],
         fc.OurName,
         m.dlMarshID  
  from db_FarLogistic.dlGroupBill b 
  left join db_FarLogistic.dlTmpMarshCost t on t.MarshID=b.MarshID and t.WorkID=b.WorkID
	left join db_FarLogistic.dlMarsh m on m.dlMarshID=b.MarshID 
 	left join def d on d.pin=b.CasherID 
  --left join DefContract dc on dc.pin=d.pin and dc.Actual=1 and dc.ContrTip in (4)
 	left join db_FarLogistic.dlDef dd on dd.id=d.pin 
  left join dbo.FirmsConfig fc on fc.our_id=14
  left join dbo.deps de on de.depid=b.depid
 	where cast(b.GivenDate as date)>=@dt1 
 				and cast(b.GivenDate as date)<=@dt2  
				and dd.nal=0 
 	order by b.GivenDate
END