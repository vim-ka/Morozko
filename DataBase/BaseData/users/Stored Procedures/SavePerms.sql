CREATE PROCEDURE users.SavePerms
@uin int,
@prg int,
@pID int
AS
BEGIN
	if exists(select 1 from dbo.PermissCurrent where prg=@prg and uin=@uin)
  begin
  	if exists(select 1 from dbo.PermissCurrent where prg=@prg and uin=@uin and Permiss&@pID<>0)
    	if @pID=1
      	delete from dbo.PermissCurrent where prg=@prg and uin=@uin
      else
      	update dbo.PermissCurrent set permiss=permiss-@pID
      	where prg=@prg and uin=@uin
    else
    	update dbo.PermissCurrent set permiss=permiss+@pID
      where prg=@prg and uin=@uin
  end
  else
  	insert into dbo.PermissCurrent(uin,prg,permiss) 
    values(@uin,@prg,case when @pID=1 then @pID else @pID+1 end)
END