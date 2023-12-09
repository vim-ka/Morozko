CREATE PROCEDURE users.AddPerms
@uin int,
@perms varchar(2500)
AS
BEGIN
  declare @sql varchar(max)
  create table ##p(prg int, pid int)
  
  set @sql='insert into ##p select '+replace(@perms,';',' union all select ')  
  exec(@sql)
  
  select prg,
  			 sum(pID) [pID]
  into #res
  from ##p
  group by prg
  
  drop table ##p
  
  alter table #res add uinHas bit not null default 0
  
  
  update #res set uinHas=case when exists(select 1
  																	 			from dbo.PermissCurrent pc
                                     			where pc.uin=@uin 
                                     			 			and pc.prg=#res.prg)
                    		  then cast(1 as bit) else cast(0 as bit) end
  declare @prg int 
  declare @pID int                  
  declare cur cursor for
  select prg, pID
  from #res
  
  open cur
  
  fetch next from cur into @prg, @pID
  
  while @@fetch_status=0
  begin
  	if exists(select 1 from dbo.PermissCurrent where uin=@uin and prg=@prg)
    	update dbo.PermissCurrent set permiss=permiss+@pID where uin=@uin and prg=@prg
    else
    	insert into dbo.PermissCurrent(uin,prg,permiss) values(@uin,@prg,@pID)
  	fetch next from cur into @prg, @pID
  end
  
  close cur
  deallocate cur
END