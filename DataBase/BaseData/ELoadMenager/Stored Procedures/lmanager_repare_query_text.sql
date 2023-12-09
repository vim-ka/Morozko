create procedure eloadmenager.lmanager_repare_query_text
@object_id int,
@qhID int
as 
begin
	set nocount on
  declare @old_text varchar(5000)
  select @old_text=h.querytext
  from eloadmenager.query_history h
  where h.qhid=@qhID
	update q set q.querytext=isnull(@old_text,q.querytext)
  from eloadmenager.querys q
  where q.object_id=@object_id
  set nocount off
end