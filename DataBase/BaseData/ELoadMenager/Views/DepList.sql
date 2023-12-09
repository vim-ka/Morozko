CREATE VIEW ELoadMenager.DepList
AS
  select depid [id], dname [list], sale [isSale]
  from dbo.deps where depid>0