CREATE view warehouse.terminal_user_list
AS
  select top 10000 u.uin, u.fio, u.pwd, iif(u.uin=0,1,pc.permiss) rights
  from dbo.usrpwd u
  join dbo.permisscurrent pc on pc.uin=u.uin
  where pc.prg=23 or u.uin=0
  group by u.uin, u.fio, u.pwd, iif(u.uin=0,1,pc.permiss)
  order by u.fio