CREATE PROCEDURE ELoadMenager.lManager_ChgObjectParent
@id int,
@parentid int
AS
BEGIN
	update ELoadMenager.objects set parentid=@parentid where id=@id
END