CREATE PROCEDURE dbo.ELoadProcesSkladTerminalCollapsed
@nd1 datetime,
@nd2 datetime,
@skladlist varchar(2000)
AS
BEGIN
	set nocount on
  DECLARE @delay INT 
  SET @delay=3600
  declare @dt datetime
  declare @tm datetime
  if object_id('tempdb..#s') is not null 
    drop table #s
  	
  create table #s (s int not null)
  insert into #s
  select distinct number
  from dbo.String_to_Int(@skladlist,',',1) 	

  create index tmp_skl_idx on #s(s)
  
  if object_id('tempdb..#tm') is not null
  	drop table #tm
    
  create table #tm(tm1 datetime, tm2 datetime)
    
  set @tm='00:00:00'
  
  while @tm<='23:59:59'
  begin
  	insert into #tm 
    values(@tm,dateadd(second,@delay-1,@tm))
    
    set @tm=dateadd(second,@delay,@tm)
  end
  
  if object_id('tempdb..#res') is not null 
    drop table #res
    
  create table #res (dt datetime,tm1 datetime,tm2 datetime)
  set @dt=@nd1
  while @dt<=@nd2
  begin
  	insert into #res
    select @dt,@dt+convert(varchar,tm1,108),@dt+convert(varchar,tm2,108)
    from #tm
    
    set @dt=dateadd(day,1,@dt)
  end
  
  drop table #tm
  
  create nonclustered index idx_tmpDT on #res(dt)
  create nonclustered index idx_tmpTM1 on #res(tm1)
  create nonclustered index idx_tmpTM2 on #res(tm2)
  
  alter table #res add CountRows int not null default 0,
  										 CountNaks int not null default 0
                       
  update #res set CountRows=isnull(
  													(select count(1) 
  													from nvzakaz z 
                            inner join #s on #s.s=z.skladNo 
                            where z.nd=#res.dt 
                             			 and cast(z.nd as datetime)+z.tm between #res.tm1 and #res.tm2),0),
  								CountNaks=isnull(
                  					(select count(distinct datnom) 
                  					from nvzakaz z 
                            inner join #s on #s.s=z.skladNo
                            where z.nd=#res.dt 
                            			and cast(z.nd as datetime)+z.tm between #res.tm1 and #res.tm2),0)
  
  select dt [Дата],
  			 convert(varchar,tm1,108) [Время1], 
         convert(varchar,tm2,108) [Время2],
         CountRows [Кол-во строк],
         CountNaks [Кол-во накладных]
  from #res
  
  drop table #res  
  drop table #s
  set nocount off
END