CREATE procedure warehouse.terminal_getinfo
as
begin
	set nocount on
	declare @terminal varchar(50)
  declare @normal_count int
  declare @terminated_count int
  declare @all_count int
  declare @notdone_count int
  declare @dt datetime
  declare @dt1 datetime
  declare @dt2 datetime
  declare @msg_sklad_lock varchar(100)
  set @normal_count=130
  set @terminal = host_name()
	set @dt=convert(varchar,getdate(),104)+' 00:00:00'
  if object_id('tempdb..#zkz') is not null drop table #zkz
	select * into #zkz from dbo.nvzakaz z where z.nd between dateadd(day,-1,@dt) and @dt+' 23:59:59'
  
  if convert(varchar,getdate(),108) between '09:00:00' and '20:59:59'
  begin
    set @dt1=convert(varchar,getdate(),104)+' 09:00:00'
    set @dt2=convert(varchar,getdate(),104)+' 20:59:59'  
  end 
  else
  begin	
    set @dt1=convert(varchar,dateadd(day,-1,getdate()),104)+' 21:00:00'
    set @dt2=convert(varchar,getdate(),104)+' 08:59:59'  
  end 

  select  @terminated_count=count(distinct z.datnom) 
  from #zkz z 
  where z.dtEnd+z.tmEnd between @dt1 and @dt2 and z.done=1 
        and (z.comp like '%'+@terminal or z.comp like '%'+@terminal+'@cancel')
        
        
  select @all_count=count(distinct z.datnom)
  from #zkz z 
  where z.nd=@dt
  
  select @notdone_count=count(distinct z.datnom )
  from #zkz z 
  where z.nd=@dt and z.done=0
  
  select @msg_sklad_lock=val from dbo.config 
	where param='msgonskladblock' and exists(select 1 from dbo.config where param='msgonskladblock' and cast(val as int)<>0)
   
  select @terminated_count [term_done], @normal_count [norm], @all_count [all], 
  			 @all_count-@notdone_count [done], @notdone_count [not_done],
         isnull(@msg_sklad_lock,'') [sklad_lock]
  if object_id('tempdb..#zkz') is not null drop table #zkz
  set nocount off
end;