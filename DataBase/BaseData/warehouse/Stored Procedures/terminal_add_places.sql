CREATE procedure warehouse.terminal_add_places
@datnom int, @skladlist nvarchar(max), @places int
as
begin
	set nocount on
  declare @tranname nvarchar(50) ='terminal_add_places', @sklad_room int =0, @res bit =0, @msg nvarchar(500) ='произошла ошибка'
  begin tran @tranname
  select @sklad_room=min(isnull(g.srid,99))
  from dbo.skladlist s 
  join dbo.skladgroups g on g.skg=s.skg
  join string_split(@skladlist,',') ss on ss.value=s.skladno  
  where g.srid>0
  insert into warehouse.sklad_order_places (datnom, srid, places)
  values(@datnom, @sklad_room, @places)
  set @res=iif(@@trancount>0,0,1)
  set @msg=iif(@res=1,@msg,'')
  if @res=0 commit tran @tranname else rollback tran @tranname
  select @res [res], @msg [msg]
  set nocount off
end