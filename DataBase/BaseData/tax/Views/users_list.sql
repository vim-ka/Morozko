CREATE view tax.users_list
as 
select top 1000 u.uin, u.fio, u.pwd, pc.permiss
from dbo.permisscurrent pc 
join dbo.usrpwd u on u.uin=pc.uin
where pc.prg=29 and pc.permiss>0
order by 2