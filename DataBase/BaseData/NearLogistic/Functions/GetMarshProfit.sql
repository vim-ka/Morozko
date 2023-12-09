CREATE FUNCTION NearLogistic.GetMarshProfit(@mhID int)
RETURNS money
AS
BEGIN
  declare @res money
  
  set @res=0/*маржа*/
  				 - NearLogistic.Marsh1CalcFact(@mhid,1,0.0) 
           - NearLogistic.Marsh1OtherExpense(@mhid)
  
  return @res
END