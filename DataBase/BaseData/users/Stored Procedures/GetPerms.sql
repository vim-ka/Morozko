CREATE PROCEDURE users.GetPerms
AS
BEGIN
  select pe.prg,
  			 pe.pID,
         pe.PermisName,
         u.uin,
         case when exists(select 1 from dbo.PermissCurrent pc where pc.prg=pe.prg and u.uin=pc.uin and pc.Permiss & pe.pID <> 0) then cast(1 as bit) else cast(0 as bit) end [HasPerms]
  from dbo.Permissions pe
  inner join dbo.usrpwd u on 1=1
  where pe.prg>0
  order by u.uin, pe.prg, pe.pID
END