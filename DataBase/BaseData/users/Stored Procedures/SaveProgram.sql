CREATE PROCEDURE users.SaveProgram
@uin int,
@prg int
AS
BEGIN
  if exists(select 1 from dbo.PermissCurrent where prg=@prg and uin=@uin)
  	delete from dbo.PermissCurrent where prg=@prg and uin=@uin
  else
  	insert into dbo.PermissCurrent(prg,uin,permiss) values(@prg,@uin,1)
END