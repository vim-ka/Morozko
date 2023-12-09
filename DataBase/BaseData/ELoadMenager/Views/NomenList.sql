CREATE VIEW [ELoadMenager].NomenList 
AS
  select x.hitag as id, x.name as list 
  from [dbo].nomen x 
  where x.Closed=0 and len(isnull(x.name,''))>3