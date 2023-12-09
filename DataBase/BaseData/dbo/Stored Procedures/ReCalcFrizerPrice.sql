CREATE PROCEDURE ReCalcFrizerPrice
AS
BEGIN
  if DATEPART(DAY,GETDATE()) = 1
  begin
    /*update Frizer set Price=StartPrice*(100-ABS(DATEDIFF(month,DateStart,GETDATE())-12)*1.11)/100
    where tip=0 and StartPrice is not Null and DATEDIFF(month,DateStart,GETDATE())>12 and DATEDIFF(month,DateStart,GETDATE())*1.11<80*/
    declare @a int
  end
END