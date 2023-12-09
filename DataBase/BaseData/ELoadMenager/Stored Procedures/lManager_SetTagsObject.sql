CREATE PROCEDURE ELoadMenager.lManager_SetTagsObject
@object_id int,
@tag_id int output,
@tag_name varchar(50),
@op int
AS
BEGIN
  if isnull(@tag_id,0)=0
  	exec ELoadMenager.lManager_SetTags @name = @tag_name, @op = @op, @id=@tag_id output
  
  if exists(select 1 from ELoadMenager.tags_to_objects ot where ot.object_id=@object_id and ot.tag_id=@tag_id)
  	delete from ELoadMenager.tags_to_objects  
    where object_id=@object_id and tag_id=@tag_id
  else
  	insert into ELoadMenager.tags_to_objects(tag_id,object_id,op) 
    values(@tag_id,@object_id,@op)
END