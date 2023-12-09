CREATE PROCEDURE ELoadMenager.lManager_DelObject
@id int,
@isDel bit
AS
BEGIN
  update ELoadMenager.objects set isdel=@isdel where id=@id
END