CREATE PROCEDURE ELoadMenager.lManager_GetTagsObject
@object_id int,
@isDel bit = 0,
@tags varchar(5000) output
AS
BEGIN
	if object_id('tempdb..#tags_') is not null drop table #tags_
  create table #tags_ (tag_id int, tag_name varchar(50), cnt int, isdel bit)
  insert into #tags_
  select tl.tag_id, tl.tag_name, tl.cnt, tl.isdel
  from ELoadMenager.TagList tl  
  where tl.tag_id in (select a.tag_id from ELoadMenager.tags_to_objects a where a.object_id=@object_id) or @object_id=0
  			and tl.isDel in (0,@isDel) 
  set @tags = ''
  set @tags= isnull(stuff(
             (select N' ['+tag_name+']' from #tags_ order by tag_id
              for xml path(''), type).value('.','varchar(max)'),1,1,''  
        			),'')  
  select tag_id, tag_name, isdel, cnt from #tags_ order by cnt desc, 2
  if object_id('tempdb..#tags_') is not null drop table #tags_
END