CREATE PROCEDURE db_FarLogistic.FillBill
@MarshID int 
AS
BEGIN
	--declare @maxbill int
	--set @maxbill=db_FarLogistic.NextBillID()
  insert into db_FarLogistic.dlGroupBill (dlGroupBillID, MarshID, WorkID, CasherID, ForPay, GivenDate, DepID) 
  select 	--row_number() over(order by tm.WorkID)+@maxbill,
					tm.MarshID*100+tm.WorkID,
					tm.MarshID, 
					tm.WorkID, 
					tm.CasherID, 
					case when tm.isFix=1 then tm.NewCost else 
					case when tm.KM+tm.delta<tm.minKM then tm.NewCost else (tm.KM+tm.delta)*tm.PalKMCost*tm.PalCount+(tm.DotsCount-2)*tm.dotCost end end+
          isnull((select sum(e.Cost) from db_FarLogistic.dlMarshExpence e where e.MarshID=tm.MarshID and e.WorkID=tm.WorkID),0), 
					getdate(),
					tm.DepID 
  from db_FarLogistic.dlTmpMarshCost tm
  where tm.MarshID=@MarshID
				and tm.WorkID<>0
END