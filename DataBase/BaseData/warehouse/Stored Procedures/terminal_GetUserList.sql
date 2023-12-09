CREATE PROCEDURE warehouse.terminal_GetUserList
AS
BEGIN
	select *,
  			 row_number() over(order by iif(id in (-1,0),'',fio),id) [RowID] 
  from (
  select u.uin [id], 
  			 u.login, 
         u.pwd, 
         u.fio, 
         iif(u.uin=0,'Служебный пользователь IT отдела',isnull(d.dname,'')+'; '+isnull(t.tname,'')) [descr],
         iif(pc.uin=0,(select sum(pID) from morozdata.dbo.permissions where prg=23),pc.permiss) [perms]
  from morozdata.dbo.usrpwd u
  join morozdata.dbo.permisscurrent pc on pc.uin=u.uin
  left join morozdata.dbo.person p on p.p_id=u.p_id
  left join morozdata.dbo.trades t on t.trid=p.trid
  left join morozdata.dbo.deps d on d.depid=p.depid
  where pc.prg=23
  
  union all
  
  select -1,
  			 '',
         '',
         'Штрихкод',
         'Авторизация по штрихкоду складского сотрудника',
         1
  ) [ResultSet]                    
END