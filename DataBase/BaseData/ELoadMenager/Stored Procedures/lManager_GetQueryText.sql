CREATE PROCEDURE ELoadMenager.lManager_GetQueryText
@ID int
AS
BEGIN
  update ELoadMenager.objects set date_lastuse=getdate() where id=@id
  
  select q.QueryText from ELoadMenager.querys q where q.object_id=@id
END