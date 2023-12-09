CREATE PROCEDURE dbo.KillWaitProcess
@msg varchar(5000) output
AS
BEGIN
	declare @spid int
  declare @er int
  declare @erOUT int
  declare @sql nvarchar(max)
  declare @host varchar(100)
   
	if @msg<>''
  begin
  	set @erOUT=0
    set @sql='kill '+@msg+' set @er=@@error'
    execute sp_executesql @sql,
    											N'@er int out',
                          @er=@erOUT out 
    
    set @msg=''    
    if @erOUT<>0 
      set @msg=@msg+'Убийство процесса '+cast(@spid as varchar)+' - НЕУДАЧА;'
    else
      set @msg=@msg+'Убийство процесса '+cast(@spid as varchar)+' - УДАЧА;'
  end
  else
  begin
  	if object_id('##ids') is not null drop table ##ids
    set @msg=''
    select s.spid, s.hostname 
    into ##ids
    from sys.sysprocesses s
    inner join (select distinct blocked [spid] from sys.sysprocesses where blocked>0) b on b.spid=s.spid
    where s.open_tran<>0 
          and s.stmt_end=-1 
          and s.stmt_start=-1 
          and s.lastwaittype='MISCELLANEOUS'
          --and hostname not like 'IT%'
          
    declare cur cursor for select spid, hostname from ##ids
    
    open cur
    
    fetch next from cur into @spid, @host
    
    while @@fetch_status=0
    begin
      set @erOUT=0
      set @sql='kill '+cast(@spid as varchar)+' set @er=@@error'
      execute sp_executesql @sql,
    												N'@er int out',
      		                  @er=@erOUT out
    	
      if @erOUT<>0 
        set @msg=@msg+'Убийство процесса '+cast(@spid as varchar)+' ,компьютер '+LTRIM(RTRIM(@host))+' - НЕУДАЧА;'+char(13)+char(10)
      else
        set @msg=@msg+'Убийство процесса '+cast(@spid as varchar)+' ,компьютер '+LTRIM(RTRIM(@host))+' - УДАЧА;'+char(13)+char(10)
    	
      fetch next from cur into @spid
    end
    
    close cur 
    deallocate cur
    drop table ##ids
  end
END