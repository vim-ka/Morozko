CREATE PROCEDURE ELoadMenager.lManager_SetObject
@ParentID int,
@Name varchar(50),
@Description varchar(1000),
@isFolder bit,
@isDel bit,
@ID int output
AS
BEGIN
	if exists(select 1 from ELoadMenager.objects where id=@ID)
  begin
  	update o set o.ParentID=@ParentID,
    						 o.name=@Name,
                 o.Description=@Description,
                 o.Date_publish=getdate(),
                 o.isDel=@isDel
    from ELoadMenager.objects o
    where o.id=@id
  end
  else
  begin
    insert into ELoadMenager.objects(ParentID,Name,Description,isFolder)
    values(@ParentID,@Name,@Description,@isFolder)
    
    select @id=max(ID) from ELoadMenager.objects
    
    exec ELoadMenager.lManager_SetUsersObject @id,-1,0
    exec ELoadMenager.lManager_SetQueryText @id, '/**/',0
  end
END