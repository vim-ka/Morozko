CREATE PROCEDURE ELoadMenager.lManager_SetReport
@object_id int,
@report varbinary(max),
@op integer
AS
BEGIN
  if exists(select 1 from ELoadMenager.reports where object_id=@object_id)
  begin
  	insert into ELoadMenager.report_history(object_id,report,op)
    select object_id, report, @op
    from ELoadMenager.reports 
    where object_id=@object_id
    
    delete from ELoadMenager.reports where object_id=@object_id
  end
  
  insert into ELoadMenager.reports
  values(@object_id,@report)
END