CREATE FUNCTION db_FarLogistic.NextBillID()
RETURNS int
AS
BEGIN
	declare @res int
	set @res=(select max(b.dlGroupBillID) from db_FarLogistic.dlGroupBill b)
	return @res
END