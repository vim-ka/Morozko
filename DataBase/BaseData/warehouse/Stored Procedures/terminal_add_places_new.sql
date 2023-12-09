CREATE procedure warehouse.terminal_add_places_new
@mhid int, @b_id int, @skladlist nvarchar(max), @places int
as
begin
	set nocount on
  declare @tranname nvarchar(50) =N'terminal_add_places_new', @sklad_room int =0, @res bit =0, @msg nvarchar(500) ='произошла ошибка'
  begin tran @tranname
  select @sklad_room=min(isnull(g.srid,99))
  from dbo.skladlist s 
  join dbo.skladgroups g on g.skg=s.skg
  join string_split(@skladlist,',') ss on ss.value=s.skladno  
  where g.srid>0
  
  insert into warehouse.sklad_order_places_new(mhid, b_id, srid, places)
  values(@mhid, @b_id, @sklad_room, @places)
  set @res=iif(@@trancount>0,0,1)
  set @msg=iif(@res=1,@msg,'')
  if @res=0 commit tran @tranname else rollback tran @tranname
  select @res [res], @msg [msg]
  set nocount off
end