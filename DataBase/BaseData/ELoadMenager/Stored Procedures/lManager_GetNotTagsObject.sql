CREATE PROCEDURE ELoadMenager.lManager_GetNotTagsObject
@object_id int
AS
BEGIN
if object_id('tempdb..#gettag') is not null drop table #gettag
create table #gettag ([tag_id] int, [tag_name] varchar(500), isdel bit, [cnt] int)
insert into #gettag
exec ELoadMenager.lManager_GetTagsObject @object_id,1,null

select tag_id, tag_name from ELoadMenager.TagList x
where not x.[tag_id] in (select [tag_id] from #gettag)
order by [tag_name]

if object_id('tempdb..#gettag') is not null drop table #gettag
END