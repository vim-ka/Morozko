CREATE procedure warehouse.terminal_divide_return
@parentid int,
@newcount int,
@groupid int 
as 
begin
	declare @tran varchar(40)
  set @tran='terminal_multiply_return'
  begin tran @tran
	insert into dbo.reqreturndet (reqretid, hitag, kol, fact_weight, groupid,sklad,ret_reason,tovprice)
	select d.reqretid, d.hitag, iif(n.flgweight=1,1,@newcount), iif(n.flgWeight=1,@newcount / 1000.0,0), @groupid,d.sklad,d.ret_reason,
  			 iif(n.flgweight=1,(d.tovprice / d.fact_weight)*(@newcount / 1000.0),d.tovprice)
  from dbo.reqreturndet d 
  join dbo.nomen n on n.hitag=d.hitag
  where d.id=@parentid  
  update d set d.kol=iif(n.flgweight=1,1,d.kol-@newcount),
  						 d.fact_weight=iif(n.flgWeight=1,d.fact_weight-@newcount / 1000.0,0)
  from dbo.reqreturndet d 
  join dbo.nomen n on n.hitag=d.hitag
  where d.id=@parentid
  if @@trancount>0 commit tran @tran
end