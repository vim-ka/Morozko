CREATE PROCEDURE users.GetProgramsList
AS
BEGIN
  select p.*, 
  			 (select count(1) from dbo.PermissCurrent pc where pc.prg=p.prg and permiss>0) [countUsers] 
  from dbo.programs p
  where p.prg>0
  order by p.prg
END