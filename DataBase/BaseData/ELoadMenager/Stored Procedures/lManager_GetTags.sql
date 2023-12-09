CREATE PROCEDURE ELoadMenager.lManager_GetTags
@tags varchar(max)
AS
BEGIN
	select l.* 
	from ELoadMenager.taglist l
	where l.tag_id in (select tag_id 
  									 from ELoadMenager.taglist 
                     except (select value [tag_id] 
                     				 from string_split(@tags,',') 
                             where rtrim(value)<>'')
                     )
END