CREATE VIEW ELoadMenager.UserList
AS
  select uin [id],
  			 isnull(fio,login) [list],
         pwd [password]
  from morozdata.dbo.usrpwd 
  where uin in (select a.uin from morozdata.dbo.permisscurrent a where a.prg=18)
  			and uin>=0