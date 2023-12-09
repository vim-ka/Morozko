CREATE procedure warehouse.terminal_shippingreturn
@id int,
@qty int,
@quality int,
@sklad int,
@mode int =-1,
@dt datetime,
@spk int,
@op int,
@groupid int,
@nondate bit =0,
@perentid int =0
as
begin
	set nocount on
  declare @reqid int, @erreg int, @res bit, @msg varchar(500), @tran varchar(50)
  set @res=0; set @erreg=0; set @msg=''; set @tran='warehouse.terminal_shippingreturn';
  
  begin tran @tran
  select @reqid=reqretid from dbo.reqreturndet where id=@id and done=0
  if @reqid is null set @erreg=1
  
  update d set d.fact_kol2=iif(n.flgweight=1,iif(@qty=0,0,d.kol),@qty),
        			 d.tovprice=iif(n.flgweight=1, (d.tovprice/d.fact_weight)*@qty/1000.0, d.tovprice),
               d.fact_weight2=iif(n.flgweight=0,d.fact_weight,@qty/1000.0),
               d.sklad=iif(@sklad=-1,d.sklad,@sklad), d.done=1, d.rqID=@quality, 
               d.fact_srokh=@dt, d.non_srokh=cast(iif(isnull(@dt,0)=0,1,0) as bit)
  from dbo.reqreturndet d
  join dbo.nomen n on d.hitag=n.hitag
  where d.id=@id
  
  if not exists(select 1 from dbo.reqreturndet where reqretid=@reqid and done=0)
  update q set q.depidcust=9, q.depidexec=29, q.tip2=194, 
               q.otv2=8612, q.rs=5, q.op=709
  from dbo.requests q  
  where q.rk=@reqid
  
  if (@erreg & 1)<>0 set @msg=@msg+'строка обработана;'+char(13)+char(10) 
  set @res=cast(iif(@erreg=0,0,1) as bit)
  if @@trancount>0 and @erreg=0 commit tran @tran else rollback tran @tran
  
  select @res [res], @msg [msg]
  set nocount off
end