CREATE PROCEDURE users.SavePerm
@pID int out,
@prg int,
@name varchar(50)
AS
BEGIN
  if @pid=0
  begin
  	select @pid=max(pID) from dbo.Permissions where prg=@prg
    set @pid=2 * @pID
  	
    insert into dbo.Permissions (prg,pid,PermisName) 
    values(@prg, @pID, @name)
  end
  else
  begin
  	update dbo.Permissions set PermisName=@name
    where prg=@prg
    			and pID=@pID
  end
END