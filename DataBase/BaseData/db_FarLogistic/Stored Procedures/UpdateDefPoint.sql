CREATE PROCEDURE db_FarLogistic.UpdateDefPoint
@pin int,
@idpoint int
AS
BEGIN
  delete from db_FarLogistic.dlDefPoint where pin=@pin
  
  insert into db_FarLogistic.dlDefPoint(IDPointList,pin) values(@idpoint,@pin)
END