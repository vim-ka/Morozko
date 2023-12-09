CREATE PROCEDURE dbo.ProcessDef @pin int, @ag_id int
AS
BEGIN
  select IsNull(sum(Kol),0)as Tara
  from TaraDet td
  where td.B_id=@pin
  
  select Count(Nom)as Friz
  from Frizer
  where B_id=@pin

  --Проверка долга

  declare @dck int
  set @dck= @pin
  update defcontract set ag_id=@ag_id where contrtip=2 and pin=@pin and dck=iif(@dck=0,dck,@dck)



  --CopyBuyerInfo

END