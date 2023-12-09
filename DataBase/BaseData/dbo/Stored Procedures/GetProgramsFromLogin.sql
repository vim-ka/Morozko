CREATE PROCEDURE dbo.GetProgramsFromLogin
@login varchar(50)
AS
BEGIN
  select prg 
  from permisscurrent p 
  inner join usrpwd u on u.uin=p.uin 
  where u.login=@login
        and p.Permiss>0
END