CREATE procedure [srv]._cleaning_tables
@pattern nvarchar(50) ='log', @pattern_not nvarchar(50) ='kassa', @name nvarchar(50) ='', 
@schema nvarchar(50) ='dbo', @database nvarchar(50) ='morozdata',
@params nvarchar(500) ='nd;nd>=''01.01.2017''', --что нужно оставить 
@mode int =0 /*0- просмотр, 1- исполнение*/,
@with_shrink bit =1
as
begin
set nocount off
declare @log_id int, @proc_params nvarchar(500), @c_name nvarchar(100)
set @proc_params=N'@pattern='''+@pattern+''',@pattern_not='''+@pattern_not+''',@name='''+@name+''''+
								 N',@schema='''+@schema+''',@database='''+@database+''',@params='''+@params+''''+
                 N',@mode='+cast(@mode as varchar)+',@with_shrink='+cast(@with_shrink as varchar) 
insert into [srv].[_cleaning_tables_log](params) values(@proc_params)
select @log_id=@@identity

set @c_name=substring(@params,1,charindex(';',@params)-1)

declare @sqlstr nvarchar(4000) =''--, @sqlwhere varchar(4000) =''
if object_id('tempdb..#tables') is not null drop table #tables
create table #tables (id int identity(1,1) primary key,table_name varchar(500), inc_field varchar(50) default '',filter_field varchar(50) default '', filtered_records int default 0, total_records int default 0,
										  sql_to_exec nvarchar(4000))
/*
set @sqlstr= 'insert into #tables (table_name) values(lower(''?''))'
set @sqlwhere= ' and xtype=''U'''
if @name='' set @sqlwhere=@sqlwhere+'and o.name like ''%'+@pattern+'%'''+iif(@pattern_not<>'',' and not o.name like ''%'+@pattern_not+'%''','') 
else set @sqlwhere=@sqlwhere+' and o.name='+''''+@name+''''
exec sp_msforeachtable @command1=@sqlstr, @whereand=@sqlwhere
*/
set @sqlstr=N'use '+@database+';'+
				 		N'insert into #tables(table_name) '+
         		N'select ''[''+table_catalog+''].[''+table_schema+''].[''+table_name+'']'' '+
				 		N'from information_schema.tables where table_type=''base table'' and schema_id(table_schema)=schema_id('''+@schema+''') '+
         		iif(isnull(@name,'')='',N'and table_name like ''%'+@pattern+'%'' and table_name not like ''%'+@pattern_not+'%''',N'and table_name='''+@name+'''')+
				 		N'order by table_catalog,table_schema,table_name'

exec sp_executesql @sqlstr         
declare @t_name varchar(50), @f_names nvarchar(4000), @inc_name varchar(50), @filter_name varchar(50), @filtered int, @total int, @filter varchar(50)
set @filter=substring(@params,charindex(';',@params)+1,len(@params))
declare crs cursor scroll for
select table_name,inc_field,filter_field from #tables
for update of inc_field,filter_field,filtered_records,total_records,sql_to_exec
open crs fetch next from crs into @t_name, @inc_name, @filter_name
while @@fetch_status=0
begin	
	set @sqlstr=N'use '+@database+';'+
  						N' update t set t.inc_field=isnull(lower((select name from sys.identity_columns where object_id=object_id('''+@t_name+'''))),''''),'+
  						N' t.filter_field=isnull(lower((select name from sys.columns where object_id=object_id('''+@t_name+''') and name like '''+@c_name+''')),'''')'+
  					  N' from #tables t'+
  						N' where current of crs'
  if isnull(@c_name,'')<>''
  exec sp_executesql @sqlstr
  fetch next from crs into @t_name, @inc_name, @filter_name
end
close crs 

delete from #tables where isnull(filter_field,'')='' 
open crs fetch first from crs into @t_name, @inc_name, @filter_name
while @@fetch_status=0
begin	
  set @sqlstr=N'select @filtered_=count(1) from '+@t_name+' where '+@filter
  exec sp_executesql @sqlstr,N'@filtered_ int output',@filtered_=@filtered output
  
  set @sqlstr=N'select @total_=count(1) from '+@t_name
  exec sp_executesql @sqlstr,N'@total_ int output',@total_=@total output
  
  update t set t.filtered_records=@filtered, t.total_records=@total
  from #tables t
  where current of crs    
  
  fetch next from crs into @t_name, @inc_name, @filter_name
end
close crs 

delete from #tables where isnull(filtered_records,0)>=isnull(total_records,0)

update l set l.fetched=(select count(1) from #tables)
from [srv].[_cleaning_tables_log] l
where ctlID=@log_id

open crs fetch first from crs into @t_name, @inc_name, @filter_name
declare @tranname nvarchar(500), @commited bit =0, @log_det_id int
    
while @@fetch_status=0
begin
	if @mode=1 set @tranname=N'cleaning...'+@t_name
  if @mode=1 begin tran @tranname
  if object_id('tempdb..tmp') is not null drop table #tmp
  select @f_names= stuff((select N','+name from sys.columns where object_id=object_id(@t_name) for xml path(''), type).value('.','varchar(max)'),1,1,'')
  set @sqlstr=N''
  set @sqlstr=N'select * into #tmp from '+@t_name+' where '+@filter+';'+char(10)
  set @sqlstr=@sqlstr+N'truncate table '+@t_name+';'+char(10)
  set @sqlstr=@sqlstr+iif(@inc_name=N'',N'',N'set identity_insert '+@t_name+N' on;'+char(10))+N'insert into '+@t_name+N'('+@f_names+')'+N' select '+@f_names+' from #tmp;'+char(10)+iif(@inc_name=N'',N'',N'set identity_insert '+@t_name+N' off;'+char(10))
  --if @with_shrink=1 set @sqlstr=@sqlstr+N'dbcc cleantable (0,'+''''+@t_name+''''+N',0) with no_infomsgs;'
  
  update t set t.sql_to_exec=@sqlstr
  from #tables t
  where current of crs
  
  if @mode=1
  begin
  	insert into [srv].[_cleaning_tables_log_det](ctlID,table_name,inc_field,filter_field,filtered_records,total_records,sql_to_exec,transaction_name)
    select @log_id,table_name,inc_field,filter_field,filtered_records,total_records,sql_to_exec,@tranname
    from #tables t 
    where table_name=@t_name
    select @log_det_id=@@identity
  end
  
  if @mode=1 exec sp_executesql @sqlstr  
  
  if object_id('tempdb..tmp') is not null drop table #tmp 
  fetch next from crs into @t_name, @inc_name, @filter_name
  if @mode=1 
  begin
  	set @commited=cast(iif(@@trancount>0,1,0) as bit)
  	if @commited=1 commit tran @tranname else rollback tran @tranname 
    
    if @with_shrink=1 and @commited=1 and @mode=1
    dbcc cleantable (0,@t_name,0) with no_infomsgs;
  	
    update l set l.commited=l.commited+iif(@commited=1,1,0)
		from [srv].[_cleaning_tables_log] l
		where ctlID=@log_det_id
    
    update d set d.transaction_end=getdate(), d.commited=@commited
		from [srv].[_cleaning_tables_log_det] d
		where ctldID=@log_det_id
  end
end
close crs; deallocate crs


if @mode=0 select * from #tables

if object_id('tempdb..#tables') is not null drop table #tables
set nocount off
end