CREATE PROCEDURE ELoadMenager.lManager_GetUsersObject
@object_id int = 0,
@users varchar(5000) out
AS
BEGIN
	if object_id('tempdb..#users_') is not null drop table #users_
	set @users = ''
  create table #users_([user_id] int, [user_name] varchar(500))
  insert into #users_
  select * from (
  select u.id [user_id], u.list [user_name]
  from ELoadMenager.UserList u
  union all
  select -1, 'Все пользователи') x
  where x.[user_id] in (select uo.user_id from ELoadMenager.users_to_objects uo where uo.object_id=@object_id) or @object_id=0
  set @users= isnull(stuff(
             (select N' ['+[user_name]+']' from #users_ order by [user_id]
              for xml path(''), type).value('.','varchar(max)'),1,1,''  
        			),'')
  select * from #users_ order by 2
  if object_id('tempdb..#users_') is not null drop table #users_
END