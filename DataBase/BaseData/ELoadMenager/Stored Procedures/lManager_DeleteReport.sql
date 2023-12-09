CREATE PROCEDURE ELoadMenager.lManager_DeleteReport
@object_id int,
@op int
AS
BEGIN
  insert into ELoadMenager.report_history(object_id,report,op)
  select object_id, report, @op
  from ELoadMenager.reports 
  where object_id=@object_id
    
  delete from ELoadMenager.reports where object_id=@object_id
END