CREATE procedure tax.set_user_sets
@usid int,
@uin int,
@stage_id int,
@isfix bit
as
begin
	if @usid=-1
  	insert into tax.user_sets(op,stage_id,isfix)
    values (@uin,@stage_id,@isfix)
  else
		update s set s.stage_id=@stage_id, s.isfix=@isfix
    from tax.user_sets s  
    where s.usid=@usid
end