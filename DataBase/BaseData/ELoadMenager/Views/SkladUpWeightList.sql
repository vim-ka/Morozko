CREATE VIEW ELoadMenager.SkladUpWeightList
AS
  select skladno [id],
  			 skladname [list]
  from [dbo].skladlist 
  where upweight=1