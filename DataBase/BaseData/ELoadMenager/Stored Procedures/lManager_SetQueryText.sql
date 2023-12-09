CREATE PROCEDURE ELoadMenager.lManager_SetQueryText
@ID int,
@QueryText varchar(5000),
@op int
AS
BEGIN
	if exists(select 1 from ELoadMenager.querys where object_id=@ID)
  begin
  	insert into ELoadMenager.query_history(object_ID,QueryText,op)
    select object_id,QueryText,@op
    from ELoadMenager.querys where object_id=@ID
    
    delete from ELoadMenager.querys where object_id=@ID 
  end
  
  insert into ELoadMenager.querys(object_id,QueryText)
  values(@ID,@QueryText)
END