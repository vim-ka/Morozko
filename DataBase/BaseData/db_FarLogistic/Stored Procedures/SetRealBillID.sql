CREATE PROCEDURE db_FarLogistic.SetRealBillID
@dlGroupBillID int,
@ID varchar(20)
AS
BEGIN
  update db_FarLogistic.dlGroupBill set RealBillID=right('00000'+@ID,4)
	where dlGroupBillID=@dlGroupBillID
END