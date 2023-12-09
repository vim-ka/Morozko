CREATE PROCEDURE users.DelPerms
@prg int,
@pID int
AS
BEGIN
  delete from dbo.Permissions where prg=@prg and pID=@pid
  
  select distinct uin
  into #usr
  from dbo.permisscurrent 
  where prg=@prg
  			and permiss & @pid<>0
        
  update dbo.PermissCurrent set Permiss=Permiss-@pID
  from dbo.PermissCurrent pc
  inner join #usr on pc.uin=#usr.uin
  where pc.prg=@prg
  
  drop table #usr
END