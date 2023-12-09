CREATE procedure CreateTrigLogOpt (@TableName VARCHAR(128), @IndexName VARCHAR(10), @PostfixTable varchar(10)) 
as

DECLARE @TN VARCHAR(3000);
DECLARE @s VARCHAR(1500);
/*
type = 0 - insert
type = 1 - delete
type = 2 - update

создаем лог таблицу с параметрами изменявшего и с сохранения значений на ins upd del
*/
begin
  declare @KolError int
  set @KolError=0
  
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
  begin transaction 
  
  if (object_id(@TableName+@PostfixTable) is null) 
  begin 
                
    --копировать структуру таблицы 
    set @TN=' select * into '+@TableName+@PostfixTable+' from '+@TableName+'; truncate table '+@TableName+@PostfixTable+'; ';
    EXECUTE (@TN); 
    if @@Error<>0 set @KolError=@KolError + 1
     
    set @TN='ALTER TABLE '+@TableName+@PostfixTable+' DROP COLUMN '+@IndexName+'; ';
    EXECUTE (@TN);
    if @@Error<>0 set @KolError=@KolError + 2
    
    --столбцы для журналирования
    set @TN=' ALTER TABLE '+@TableName+@PostfixTable+' ADD [LogID] int  IDENTITY(1, 1) NOT NULL; '+ 
            ' ALTER TABLE '+@TableName+@PostfixTable+' ADD ['+@IndexName+'] int  NOT NULL; '+ 
            ' ALTER TABLE '+@TableName+@PostfixTable+' ADD [type] smallint NULL; '+
            ' ALTER TABLE '+@TableName+@PostfixTable+' ADD [user_name] nvarchar(256) default suser_sname() NULL; '+
            ' ALTER TABLE '+@TableName+@PostfixTable+' ADD [datetime] datetime default getdate() NULL; '+
            ' ALTER TABLE '+@TableName+@PostfixTable+' ADD [host_name] nchar(30) default host_name() NULL; '+
            ' ALTER TABLE '+@TableName+@PostfixTable+' ADD [app_name] nvarchar(128) default app_name() NULL; ';      
    EXECUTE (@TN);   
    if @@Error<>0 set @KolError=@KolError + 4
          
    --описание столбцов для журналирования   
    EXECUTE (' EXEC sp_addextendedproperty ''MS_Description'', N''тип изменения 0 - insert, 1 - delete, 2 - update'', N''schema'', N''dbo'', N''table'', N'''+@TableName+@PostfixTable+''', N''column'', N''type''; ');
    if @@Error<>0 set @KolError=@KolError + 8
    EXECUTE (' EXEC sp_addextendedproperty ''MS_Description'', N''имя пользователя'', N''schema'', N''dbo'', N''table'', N'''+@TableName+@PostfixTable+''', N''column'', N''user_name'';');
    if @@Error<>0 set @KolError=@KolError + 16
    EXECUTE (' EXEC sp_addextendedproperty ''MS_Description'', N''время изменения'', N''schema'', N''dbo'', N''table'', N'''+@TableName+@PostfixTable+''', N''column'', N''datetime'';');  
    if @@Error<>0 set @KolError=@KolError + 32
    EXECUTE (' EXEC sp_addextendedproperty ''MS_Description'', N''имя компа'', N''schema'', N''dbo'', N''table'', N'''+@TableName+@PostfixTable+''', N''column'', N''host_name'';');
    if @@Error<>0 set @KolError=@KolError + 64
  	EXECUTE (' EXEC sp_addextendedproperty ''MS_Description'', N''имя приложения'', N''schema'', N''dbo'', N''table'', N'''+@TableName+@PostfixTable+''', N''column'', N''app_name'';');
    if @@Error<>0 set @KolError=@KolError + 128
    
  																												
      --получим список столбцов
      set @s = '';
      select @s = @s + t.name + ', ' from(
      select COLUMN_NAME name from INFORMATION_SCHEMA.COLUMNS
      where TABLE_NAME = @TableName
      ) t; 
  
      --триггер на insert
      SET @TN = ' create trigger trg_'+@TableName+'_i
      on '+@TableName+'
      for insert
      as
      begin
          insert into '+@TableName+@PostfixTable+' ('+@s+'[type])
          select '+@s+'0  from inserted
      end ';    
      EXECUTE (@TN);
      if @@Error<>0 set @KolError=@KolError + 256
    
      
       --триггер на delete
      SET @TN = ' create trigger trg_'+@TableName+'_d
      on '+@TableName+'
      for delete
      as
      begin
          insert into '+@TableName+@PostfixTable+' ('+@s+'[type])
          select '+@s+'1 from deleted
      end ';    
      EXECUTE (@TN);
      if @@Error<>0 set @KolError=@KolError + 512
     
      
       --триггер на update
      SET @TN = ' create trigger trg_'+@TableName+'_u
      on '+@TableName+'
      for update
      as
      begin
          insert into '+@TableName+@PostfixTable+' ('+@s+'[type])
          select '+@s+'2 from inserted
      end ';    
      EXECUTE (@TN);
      if @@Error<>0 set @KolError=@KolError + 1024
    
    if @KolError = 0 
    begin
      SELECT 'Журналирование таблицы '+@TableName+' создано';     
      COMMIT;
    end  
    else
    begin
      SELECT 'Ошибка создания логирования', @KolError; 
      ROLLBACK;
    end
  end
  else SELECT 'Журналирование таблицы '+@TableName+' уже существует'; 

end