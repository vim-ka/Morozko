create procedure warehouse.terminal_union_return
@id int,
@groupid int
as 
begin
	declare @tran varchar(40)
  set @tran='terminal_union_return'
  begin tran @tran	
  declare @hitag int
  declare @reqnum int
  declare @newid int
  declare @flgweight bit
  declare @weight decimal(15,2)
  declare @kol int 
  select @hitag=d.hitag, @flgweight=n.flgweight, @weight=d.fact_weight, @kol=d.kol, @reqnum=d.reqretid
  from dbo.reqreturndet d
  join dbo.nomen n on n.hitag=d.hitag 
  where d.id=@id  
  if exists(select 1 from dbo.reqreturndet where hitag=@hitag and id<>@id and reqretid=@reqnum)
  begin
  	select @newid=min(id) from dbo.reqreturndet where id<>@id and reqretid=@reqnum
    update d set d.kol=iif(@flgweight=1,1,d.kol+@kol),
                 d.fact_weight=iif(@flgWeight=1,d.fact_weight+@weight,0)
    from dbo.reqreturndet d 
    where d.id=@newid
    delete from dbo.reqreturndet where id=@id    
  end
  if @@trancount>0 commit tran @tran
end