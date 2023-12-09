CREATE PROCEDURE users.GetPrograms
AS
BEGIN
  select pr.prg,
  			 pr.prgname,
         u.uin,
         case when exists(select 1 from dbo.PermissCurrent pc where pc.uin=u.uin and pc.prg=pr.prg) then cast(1 as bit) else cast(0 as bit) end [HasPrg]
  from dbo.programs pr
  inner join dbo.usrpwd u on 1=1
  where pr.Prg>0
  order by u.uin, pr.prg
END