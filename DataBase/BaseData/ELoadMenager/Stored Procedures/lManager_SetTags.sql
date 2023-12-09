CREATE PROCEDURE ELoadMenager.lManager_SetTags
@name varchar(50),
@op int,
@id int output
AS
BEGIN
  insert into ELoadMenager.tags (name, op) values(@name, @op)
  
  select @id=max(id) from ELoadMenager.tags
END