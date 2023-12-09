CREATE PROCEDURE ELoadMenager.lManager_SetUsersObject
@id int,
@user_id int,
@op int
AS
BEGIN
  if exists(select 1 from ELoadMenager.users_to_objects where user_id=@user_id and object_id=@id)
  	delete from ELoadMenager.users_to_objects where user_id=@user_id and object_id=@id
  else
  	insert into ELoadMenager.users_to_objects(object_id,user_id,op) values(@id, @user_id,@op) 
END