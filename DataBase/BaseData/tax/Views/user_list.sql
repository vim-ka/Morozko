CREATE view tax.user_list
as
	select u.uin, u.fio--, s.stage_id, s.isfix,l.deep,l.deep_out,isnull(s.usID,-1) [usID]
	from dbo.usrpwd u
	join dbo.permisscurrent pc on pc.uin=u.uin
	--left join tax.user_sets s on s.op=u.uin 
	--join tax.stage_list l on l.id=isnull(s.stage_id,-1)
	where pc.prg=29