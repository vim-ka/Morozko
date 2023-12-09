CREATE PROCEDURE users.GetPersonNewUser
AS
BEGIN
  select  p.p_id,
  				p.fio,
          isnull(d.DName,'не определен') [Dep],
          isnull(t.tName,'не определен') [Trade]
  from dbo.person p
  left join dbo.deps d on d.DepID=p.DepID
  left join dbo.trades t on t.trID=p.trID
  where not exists(select 1 from dbo.usrpwd u where u.p_id=p.p_id)
  			and p.HRPersID>0
        and p.Closed=0
END