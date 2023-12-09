CREATE PROCEDURE ELoadMenager.lManager_GetNotUsersObject
@object_id int
AS
BEGIN
if object_id('tempdb..#getuser') is not null drop table #getuser
create table #getuser ([user_id] int, [user_name] varchar(500))
insert into #getuser
exec ELoadMenager.lManager_GetUsersObject @object_id,null

select * from (
select id [user_id], list [user_name] from ELoadMenager.UserList 
union all
select -1, 'Все пользователи') x
where not x.[user_id] in (select [user_id] from #getuser)
order by [user_name]

if object_id('tempdb..#getuser') is not null drop table #getuser
END