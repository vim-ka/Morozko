CREATE PROCEDURE users.SavePermsToAll
@prg int,
@pID int,
@uins varchar(2500),
@act bit --0 удаление 1 добавление
AS
BEGIN
	if @uins=''
		select distinct uin
  	into ##usr
  	from dbo.permisscurrent pc
  	where pc.Permiss>0
  else
  begin
  	declare @sql varchar(max)
    set @sql='select distinct uin into ##usr from dbo.PermissCurrent pc where pc.permiss>0 and pc.uin in ('+@uins+')'
    exec(@sql)
  end
  
  if @act=1
  begin
  	delete from ##usr 
    where exists(select 1 
                  from dbo.PermissCurrent pc 
                  where pc.uin=##usr.uin 
                        and pc.prg=@prg 
                        and pc.Permiss & @pID <>0)
        
    declare @uin int
    
    declare cur cursor for 
    select uin from ##usr 
    
    open cur
    
    fetch next from cur into @uin 
    
    while @@fetch_status=0 
    begin
    	if exists(select 1 from dbo.permisscurrent where prg=@prg and uin=@uin)
      	update dbo.permisscurrent set permiss=permiss+@pID
        where prg=@prg and uin=@uin
      else 
      	insert into dbo.permisscurrent (uin,prg,permiss) 
        values(@uin,@prg,case when @pID & 1=0 then @pID+1 else @pID end)
        
    	fetch next from cur into @uin
    end 
    
    close cur
    deallocate cur
  end
  else
  begin
  	--delete from ##usr where exists(select 1 from dbo.PermissCurrent pc where pc.uin=##usr.uin and pc.prg=@prg and pc.Permiss & @pID =0)
    
    if @pID=1 
    	delete from dbo.PermissCurrent where prg=@prg
    else
    	update dbo.PermissCurrent set Permiss=Permiss-@pID
      from dbo.PermissCurrent pc
      inner join ##usr on pc.uin=##usr.uin
      where pc.prg=@prg
  end
  
  drop table ##usr
END