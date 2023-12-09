CREATE procedure warehouse.terminal_gang_create
@spks nvarchar(1000),
@skladlist nvarchar(1000) =''
as
begin
	set nocount on
  declare @err int
  declare @id int 
  set @err=0
  set @id=0
	declare @tranname varchar(20) 
  set @tranname='terminal_gang_create'
  begin tran @tranname
  insert into warehouse.sklad_gang_history(spks,skladlist) select @spks, @skladlist
  select @id=@@identity
  insert into warehouse.sklad_gang
  select @id, a.value [spk] from string_split(@spks,',') a
  if @err=0 commit tran @tranname 
  else rollback tran @tranname
  select @id [group_id]
  set nocount off
end