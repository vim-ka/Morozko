CREATE PROCEDURE users.GetDonorList
AS
BEGIN
  select u.uin, u.fio
  from usrpwd u
  where exists(select 1 from permisscurrent pc where pc.uin=u.uin and pc.Permiss>0)
  			and u.uin>0
  union all
  select -1, 'только заявки'
END