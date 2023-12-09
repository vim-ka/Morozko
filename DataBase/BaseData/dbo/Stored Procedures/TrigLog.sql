CREATE procedure TrigLog (@TableName VARCHAR(128),@TableIDName VARCHAR(128)) 
as

DECLARE @TN VARCHAR(500);
DECLARE @s VARCHAR(500);
/*
type = 0 - insert
type = 1 - delete
type = 2 - update

создаем лог таблицу с параметрами изменявшего и с сохранения значений на ins upd del
*/
begin

  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
  begin transaction 

  if (object_id(@TableName+'Log') is null) 
  begin 
                
    --копировать структуру таблицы 
    set @TN=' select * into '+@TableName+'Log from '+@TableName+'; truncate table '+@TableName+'Log; ';
    EXECUTE (@TN); 
     
    set @TN='ALTER TABLE '+@TableName+'Log  DROP COLUMN  '+@TableIDName;
    EXECUTE (@TN);
    
    --столбцы для журналирования
    set @TN=' ALTER TABLE '+@TableName+'Log ADD '+@TableName+'LogID  int  IDENTITY(1, 1) NOT NULL; '+ 
          ' ALTER TABLE '+@TableName+'Log ADD '+@TableIDName+'   int  NOT NULL; '; 
    EXECUTE (@TN);      
    set @TN=' ALTER TABLE '+@TableName+'Log ADD [type]             smallint NULL; '+
          ' ALTER TABLE '+@TableName+'Log ADD [user_name]        nvarchar(256) default suser_sname() NULL; '+
          ' ALTER TABLE '+@TableName+'Log ADD [datetime]         datetime default getdate() NULL; '+
          ' ALTER TABLE '+@TableName+'Log ADD [host_name]        nchar(30) default host_name() NULL; '+
          ' ALTER TABLE '+@TableName+'Log ADD [app_name]         nvarchar(128) default app_name() NULL; ';      
    EXECUTE (@TN);   
          
    --описание столбцов для журналирования   
    EXECUTE (' EXEC sp_addextendedproperty ''MS_Description'', N''тип изменения 0 - insert, 1 - delete, 2 - update'', N''schema'', N''dbo'', N''table'', N'''+@TableName+'Log'', N''column'', N''type''; ');
    EXECUTE (' EXEC sp_addextendedproperty ''MS_Description'', N''имя пользователя'', N''schema'', N''dbo'', N''table'', N'''+@TableName+'Log'', N''column'', N''user_name'';');
    EXECUTE (' EXEC sp_addextendedproperty ''MS_Description'', N''время изменения'', N''schema'', N''dbo'', N''table'', N'''+@TableName+'Log'', N''column'', N''datetime'';');  
    EXECUTE (' EXEC sp_addextendedproperty ''MS_Description'', N''имя компа'', N''schema'', N''dbo'', N''table'', N'''+@TableName+'Log'', N''column'', N''host_name'';');
  	EXECUTE (' EXEC sp_addextendedproperty ''MS_Description'', N''имя приложения'', N''schema'', N''dbo'', N''table'', N'''+@TableName+'Log'', N''column'', N''app_name'';');
    
  																												
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
          insert into '+@TableName+'Log ('+@s+'[type])
          select '+@s+'0  from inserted
      end ';    
      EXECUTE (@TN);
    
      
       --триггер на delete
      SET @TN = ' create trigger trg_'+@TableName+'_d
      on '+@TableName+'
      for delete
      as
      begin
          insert into '+@TableName+'Log ('+@s+'[type])
          select '+@s+'1 from deleted
      end ';    
      EXECUTE (@TN);
     
      
       --триггер на update
      SET @TN = ' create trigger trg_'+@TableName+'_u
      on '+@TableName+'
      for update
      as
      begin
          insert into '+@TableName+'Log ('+@s+'[type])
          select '+@s+'2 from inserted
      end ';    
      EXECUTE (@TN);
      
     SELECT 'Журналирование таблицы '+@TableName+' создано';     
  end
  else SELECT 'Журналирование таблицы '+@TableName+' уже существует'; 
  COMMIT;
end