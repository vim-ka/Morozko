CREATE procedure warehouse.terminal_check_order_composition
@tip int,@mhid int,@datnom int,@hitag int,
@qty int, --кол-во, если вес то в граммах
@op int,@spk int,@groupid int 
as
begin
	set nocount on
	declare @res bit =cast(0 as bit), @msg varchar(500) ='', @id int
  select @id=id from warehouse.sklad_mobiletermdata where mhid=@mhid and datnom=@datnom and hitag=@hitag --and tip=@tip
  if isnull(@id,0)=0
  begin
  	insert into warehouse.sklad_mobiletermdata(tip,mhid,datnom,hitag,kol,op,spk,groupid,compname)
    values(0/*@tip*/,@mhid,@datnom,@hitag,@qty,@op,@spk,@groupid,host_name())
    select @id=@@identity
  end
  else
  begin
  	update mm set mm.kol=/*mm.kol+*/@qty, mm.op=@op, 
    			 mm.spk=@spk, mm.groupid=@groupid,
           mm.compname=host_name()
    from warehouse.sklad_mobiletermdata mm
    where mm.id=@id
  end
  set @msg=case when isnull(@id,0)=0 then 'Ошибка вставки лога'
  						  when @id>0 then cast(@id as int) end
  select @res [res], @msg [msg]
  set nocount off
end