CREATE VIEW ELoadMenager.YesNoAllList
AS
  select 0 [id], 'нет' [list] 
  union 
  select 1,'да'
  union 
  select -1,'все'