CREATE PROCEDURE dbo.GetEntityAtribute @EntID int, @ID int
AS
BEGIN
  declare @TableTagName varchar(200)--,@EntNameID varchar(50)
  declare @sql_code varchar(1000)

  select @TableTagName=EntTagsName from Entity where EntID=@EntID
  
  set @sql_code=
  ' select t.TagID, t.TagValue, t.TagvalueString, t.ID, g.TagName,g.TagType, g.TagActions, r.isFixed, r.isReq, 1 as inVal,g.TagParent from '
  + @TableTagName
  +' t join Tags g on t.TagID=g.TagID'
  +' join TagsRules r on r.TagID=g.TagID'
  +' where t.ID='
  + cast(@ID as varchar)
  +' union'
  +' select g.TagID, cast(0 as sql_variant) as TagValue, '''' as TagvalueString, 0 as ID, g.TagName, g.TagType, g.TagActions, r.isFixed, r.isReq, 0 as inVal, g.TagParent from '
  +' TagsRules r join Tags g on r.TagID=g.TagID'
  +' where r.EntID='
  + cast(@EntID as varchar)
  +' and g.TagID not in '
  +' (select t.TagID from '
  + @TableTagName
  +'t join TagsRules r on r.TagID=t.TagID'
  +' where t.ID=' + cast(@ID as varchar)+')'
  +' order by TagParent,TagName'
  --select @sql_code  
  exec(@sql_code)
END