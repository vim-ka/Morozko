CREATE PROCEDURE ELoadMenager.lManager_GetReport
@object_id int
AS
BEGIN
	update ELoadMenager.objects set date_lastprint=getdate() where id=@object_id
  
  select q.report from ELoadMenager.reports q where q.object_id=@object_id
END