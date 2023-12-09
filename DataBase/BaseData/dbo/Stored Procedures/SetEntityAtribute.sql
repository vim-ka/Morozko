CREATE PROCEDURE dbo.SetEntityAtribute @EntID int, @ID int, @TagID int, @TagValue sql_variant, @TagValueString varchar(200), @OP int
AS
BEGIN
  declare @TableTagName varchar(200)--,@EntNameID varchar(50)
  declare @sql_code varchar(1000)

  select @TableTagName=EntTagsName from Entity where EntID=@EntID
  
  set @sql_code=
  ' if EXISTS(select * from '
  + @TableTagName
  +' where ID='+ cast(@ID as varchar) +' and TagID='+ cast(@TagID as varchar) +' ) update '+ @TableTagName
  +' set TagValue=''' + cast(@TagValue as varchar)
  +''', TagValueString=''' + @TagValueString
  +''' where ID='+cast(@ID as varchar)
  +' and TagID='+cast(@TagID as varchar)
  +' else'
  +' insert into ' + @TableTagName+' (ID, TagID, TagValue, TagValueString, OP, Comp, ND)' 
  +' values ('
  +cast(@ID as varchar)+','
  +cast(@TagID as varchar)+','
  +''''+cast(@TagValue as varchar)+''','
  +''''+@TagValueString+''','
  +cast(@OP as varchar)+','
  +' host_name(),'
  +'getdate()'
  +');'
  
 --select @sql_code  
  exec(@sql_code)
END