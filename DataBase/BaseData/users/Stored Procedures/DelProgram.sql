CREATE PROCEDURE users.DelProgram
@prg int
AS
BEGIN
  delete from dbo.Programs where prg=@prg
  
  delete from dbo.permisscurrent where prg=@prg
END