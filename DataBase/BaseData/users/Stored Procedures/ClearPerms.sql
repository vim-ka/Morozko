CREATE PROCEDURE users.ClearPerms
@uin int
AS
BEGIN
  delete from dbo.PermissCurrent where uin=@uin
END