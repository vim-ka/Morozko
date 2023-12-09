CREATE PROCEDURE users.GetUsers
@prg varchar(500)='',
@perms varchar(500)='',
@closed varchar(3)='',
@fio varchar(500)='',
@uin varchar(500)='',
@p_id varchar(500)=''
AS
BEGIN
  declare @sql varchar(max)
  set @sql=''
  
  select u.uin, 
  			 p.p_id, 
         u.login,
         u.pwd, 
         case when len(u.fio)<3 then p.fio else u.fio end [fio], 
         case when u.uin=0 then cast(0 as bit) else cast(isnull(p.closed,1) as bit) end [closed],
         case when not exists(select 1 from dbo.permisscurrent pc where pc.uin=u.uin) then cast(1 as bit) else cast(0 as bit) end [empty],
         isnull(u.Prikaz,'') [prikaz]
  into ##res
  from dbo.usrPwd u
  left join dbo.person p on p.p_id=u.p_id
  
  if @p_id<>''
  begin
  	set @sql='delete from ##res where not p_id in ('+@p_id+')'
    exec(@sql)
  end
  
  if @uin<>''
  begin
  	set @sql='delete from ##res where not uin in ('+@uin+')'
    exec(@sql)
  end
  
  if @fio<>''
  begin
  	set @sql='delete from ##res where not fio like '''+'%'+@fio+'%'+''''
    exec(@sql)
  end
  
  if @closed<>''
  begin
  	set @sql='delete from ##res where not closed in ('+@closed+')'
    exec(@sql)
  end
  
  if @prg<>''
  begin
  	if @perms<>''
    begin
    	create table ##perms(pID int)
			set @perms='insert into ##perms select '+replace(@perms,',',' union all select ')
			exec(@perms)
      
      set @sql='delete from ##res where not exists(select 1
                                                   from PermissCurrent pc 
                                                   where pc.uin=##res.uin 
                                                   and pc.prg in ('+@prg+')
                                                   and not exists(select 1 
                                                   								from ##perms 
                                                                  where pc.Permiss & ##perms.pID = 0))'
      exec(@sql)
      
      drop table ##perms
    end
    else
    begin
      set @sql='delete from ##res where not exists(select 1 from dbo.permisscurrent pc where pc.uin=##res.uin and pc.prg in ('+@prg+'))'
      exec(@sql)
    end
  end
    
  select *, 
  			 case when uin=0 then 0 else case when isnull(closed,1)=1 then 2 else case when [empty]=1 then 3 else -1 end end end [clr] 
  from ##res 
  order by fio
    
  drop table ##res
END