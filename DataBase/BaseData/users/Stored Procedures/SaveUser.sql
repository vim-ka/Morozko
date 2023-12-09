CREATE PROCEDURE users.SaveUser
@p_id int,
@fio varchar(70),
@login varchar(20),
@pwd varchar(32),
@donor int,
@uin int out,
@prikaz varchar(50)
AS
BEGIN
  if @uin=0
  begin
  set @uin=100
  
  if len(@fio)<3 select @fio=fio from dbo.person where p_id=@p_id
  
  select uin
  into #reserved 
  from dbo.usrpwd
  
  while exists(select 1 from #reserved where uin=@uin)
  	set @uin=@uin+1
    
  insert into usrpwd(uin,login,fio,p_id,pwd,prikaz) values(@uin,@login,@fio,@p_id,@pwd,@prikaz)
  
  if @donor=-1
  	insert into dbo.permisscurrent(uin,p_id,prg,permiss) values(@uin, @p_id, 17,1)
  else
  	insert into dbo.PermissCurrent (uin, prg, permiss)
    select @uin, prg, permiss 
    from dbo.PermissCurrent 
    where uin=@donor
    
  drop table #reserved
  end
  else
  begin
  	declare @prg int
    declare @permiss int 
    
  	update dbo.usrpwd set p_id=@p_id,
    										  fio=@fio,
                          login=@login,
                          pwd=@pwd,
                          prikaz=@prikaz
    where uin=@uin 
    
    if @uin<>@donor 
    begin
    	select x.prg,
             sum(x.pid) Permiss
      into #perms
      from (
      select p.prg,
             p.pID,
             case when exists(select 1 
                              from dbo.PermissCurrent pc 
                              where pc.uin=@donor 
                                    and pc.prg=p.prg 
                                    and pc.Permiss & p.Pid<>0) 
             then cast(1 as bit) else cast(0 as bit) end [donorPerms],
             case when exists(select 1 
                              from dbo.PermissCurrent pc 
                              where pc.uin=@uin 
                                    and pc.prg=p.prg 
                                    and pc.Permiss & p.Pid<>0) 
             then cast(1 as bit) else cast(0 as bit) end [uinPerms]
      from permissions p ) x
      where x.[donorPerms]=1 and x.[uinPerms]=0
      group by x.prg
      
      declare cur cursor for
      select prg, Permiss from #perms 
      
      open cur
      
      fetch next from cur into @prg, @permiss
      
      while @@fetch_status=0
      begin
      	if exists(select 1 from dbo.PermissCurrent pc where pc.uin=@uin and pc.prg=@prg)
        	update dbo.PermissCurrent set permiss=permiss+@permiss
          where uin=@uin
          			and prg=@prg
       	else
        	insert into dbo.PermissCurrent(uin,p_id,prg,Permiss) 
          values(@uin,@p_id,@prg,@permiss)
        
        fetch next from cur into @prg, @permiss
      end
      
      close cur
      deallocate cur
      drop table #perms
    end
  end
END