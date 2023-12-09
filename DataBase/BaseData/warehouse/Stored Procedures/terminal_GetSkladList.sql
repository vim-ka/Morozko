CREATE PROCEDURE warehouse.terminal_GetSkladList
AS
BEGIN
  select skladno [id],
         '['+cast(skladno as varchar)+'] '+skladname [name],
         'Наборка - '+skgname [descr],
         row_number() over(order by s.upweight desc,g.our_id,iif(s.skladno>199,1,0),s.skladname,s.skladno) [rowID],
         upweight 
  from maindata.dbo.skladlist s
  left join maindata.dbo.skladgroups g on g.skg=isnull(s.skg,0)   
  --where aginvis=0
  
END