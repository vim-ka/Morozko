CREATE VIEW ELoadMenager.SaleDepsList
AS
  select depid [id], dname [list] from [dbo].deps where sale=1