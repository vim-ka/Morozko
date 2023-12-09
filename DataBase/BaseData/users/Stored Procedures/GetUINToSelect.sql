CREATE PROCEDURE users.GetUINToSelect
@prg int,
@pID int,
@act bit --1 добавление 0 удаление 
AS
BEGIN
	if @act=0
  begin
  if @pID=0
    select cast(0 as bit) [x],
    			 u.uin [id],
           u.fio [list]
    from dbo.PermissCurrent pc
    inner join dbo.usrpwd u on pc.uin=u.uin
    where pc.prg=@prg
    			and pc.Permiss>0
    order by 3
  else
  	select cast(0 as bit) [x],
    			 u.uin [id],
           u.fio [list]
    from dbo.PermissCurrent pc
    inner join dbo.usrpwd u on pc.uin=u.uin
    where pc.prg=@prg
    			and pc.Permiss & @pID<>0
    order by 3		
  end
  else
  begin
  	select distinct
    			 cast(0 as bit) [x],
    			 u.uin [id],
           u.fio [list]
    from dbo.PermissCurrent pc
    left join dbo.usrpwd u on pc.uin=u.uin
    where pc.Permiss>0
    order by 3
  end
END