CREATE procedure srv.create_logging_trigger_for_update
@target_table_db_name nvarchar(128) =N'', @target_table_schema_name nvarchar(128) =N'dbo', @target_table_name nvarchar(128) =N'',
@target_table_key nvarchar(128) =N'' --если пустое то будет автоинкрементное поле
as 
begin
	set nocount on
	declare @tranname nvarchar(100) =N'create_logging_trigger_for_update', @sql nvarchar(max) =N'', 
  				@target_table_name_full nvarchar(128) =N''+@target_table_db_name+'.'+@target_table_schema_name+'.'+@target_table_name,
  				@log_header_table nvarchar(100) =@target_table_name+N'_log_header',@log_detail_table nvarchar(100) =@target_table_name+N'_log_detail'
  if object_id(@target_table_name) is not null 
  begin
  	set transaction isolation level serializable
    begin tran @tranname
    
    if isnull(@target_table_key,'')='' select @target_table_key=name from sys.columns where object_id=object_id(@target_table_name_full) and is_identity=1
    --создание головной таблицы логов  
    if object_id(@log_header_table) is null 
    begin
    	set @sql=N'create table '+@log_header_table+' ('+
      				 N'[log_id] int not null identity(1,1) primary key,'+
               N'[log_date] datetime not null default getdate(),'+
               N'[host_name] nvarchar(256) not null default host_name(),'+
               N'[application_name] nvarchar(256) not null default app_name(),'+
               N'[user_name] nvarchar(256) not null default suser_sname(),'+
               N'[type] int not null'+
               N'['+@target_table_key+'] int not null)'
      exec sp_executesql @sql
    end
    
    --создание детализации таблицы логов
    if object_id(@log_detail_table) is null
    begin
    	set @sql=N'create table '+@log_detail_table+' ('+
      				 N'[log_det_id] int not null identity(1,1) primary key,'+
               N'[log_id] int not null,'+
               N'[field_name] nvarchar(128) not null'+
               N'[old_value] sql_variant null'+
               N'[new_value] sql_variant null'
    	exec sp_executesql @sql
    end
    
    set @sql=
    	N' use '+@target_table_db_name+'; '+
    	N' create trigger '+@target_table_schema_name+'.trg_'+@target_table_name+'_log on '+@target_table_schema_name+'.'+@target_table_name+' for insert, update, delete as'+
      N' begin'+
      N' declare @type int'+
      N' if object_id(''tempdb..#'+@target_table_db_name+'_buffer'') is not null drop table #'+@target_table_db_name+'_buffer'+
      N' set @type= case when exists(select 1 from inserted) and exists(select 1 from deleted) then 0 when exists(select 1 from inserted) and not exists(select 1 from deleted) then 1 when not exists(select 1 from inserted) and exists(select 1 from deleted) then 2 else -1 end;'+
      N''+
      N''+
      N''+
      N''+
      N''+
      N''+
      N''+
      N''+
      N''+
      N''+
      N''+
      N''+
      N''+
      N''+
      N' if object_id(''tempdb..#'+@target_table_db_name+'_buffer'') is not null drop table #'+@target_table_db_name+'_buffer'+
      N' end'
    
    if @@trancount>0 commit tran @tranname
    else rollback tran @tranname
  end
  set nocount off
end