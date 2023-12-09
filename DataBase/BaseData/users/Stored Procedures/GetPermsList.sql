CREATE PROCEDURE users.GetPermsList
AS
BEGIN
  select p.*,
  			 (select count(1) from dbo.PermissCurrent pc where pc.prg=p.prg and pc.Permiss & p.pID <>0) [countUsers]
  from Permissions p
  order by p.prg,p.pID  
END