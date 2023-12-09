CREATE procedure CreateBTrigLog (@SchemaName VARCHAR(128), @TableName VARCHAR(128), @IndexName VARCHAR(10), @PostfixTable varchar(10)) 
as

DECLARE @TN VARCHAR(3000);
DECLARE @s VARCHAR(1500);
DECLARE @TABLEN varchar(100);
set @TABLEN=@TableName+@PostfixTable;

begin
  declare @KolError int
  set @KolError=0
  
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
  begin transaction 
  
  if (object_id(@TABLEN) is null) 
  begin 
  set @TN=
    'create table ['+ @SchemaName +'].'+@TABLEN  +'
    ([ISPR] int  IDENTITY(1, 1) NOT NULL,
    [ND] datetime default getdate() NULL,
    [user_name] nvarchar(256) default suser_sname() NULL,
    [host_name] nchar(30) default host_name() NULL,
    [app_name] nvarchar(128) default app_name() NULL,
    [type] smallint NULL,
    ['+@IndexName+'] int  NOT NULL)'
   
    EXECUTE (@TN); 
  
    if @@Error<>0 set @KolError=@KolError + 2
  end 
   
  if (object_id(@TableName+@PostfixTable+'DET') is null) 
  begin
    set @TN=
   
    'create table ['+ @SchemaName +'].'+ @TABLEN+'DET 
    ([ISPR_DET] int  IDENTITY(1, 1) NOT NULL,
    [ISPR] int NOT NULL,
    [FieldName] varchar(128) NULL,
    [Old_Value] sql_variant NULL,
    [New_Value] sql_variant NULL
    )'
    
     EXECUTE (@TN); 
     
    if @@Error<>0 set @KolError=@KolError + 4        
   end           
     
      
    --триггер на update
    SET @TN = ' create trigger trg_'+@TableName+'_u
      on ['+ @SchemaName +'].'+@TableName+'
      for update
      as
      begin
        declare @K int, @KD int, @FieldName varchar(50), @Temp sql_variant, @TempOLD sql_variant, @First bit
        declare @TN nvarchar(500)
        DECLARE @ParmDefinition nvarchar(500)
        set @First=1
        Declare @CURSOR Cursor  

        set @CURSOR  = Cursor scroll
        for select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS
        where TABLE_NAME ='''+ @TableName+''' and TABLE_SCHEMA=''' + @SchemaName + '''     
        open @CURSOR
        

        
        select 0 as nom,i.* into #TempTable from inserted i inner join inserted i1 on i.'+@IndexName+'=i1.'+@IndexName+'
        
        insert into #TempTable select 1 as nom,* from deleted

        fetch next from @CURSOR into @FieldName


        while @@FETCH_STATUS = 0
        begin
        
             set @K=(select '+ @IndexName +' from deleted)
            
             SET @ParmDefinition = N''@Temp1 sql_variant OUTPUT'';
             set @TN=N''set @Temp1=(select ''+@FieldName+'' from #TempTable where Nom=0)''
             EXEC sp_executeSQL @TN, @ParmDefinition, @Temp1=@Temp OUTPUT
             
             SET @ParmDefinition = N''@TempOLD1 sql_variant OUTPUT'';
             set @TN=N''set @TempOLD1=(select ''+@FieldName+'' from #TempTable where Nom=1)''
             EXEC sp_executeSQL @TN, @ParmDefinition, @TempOLD1=@TempOLD OUTPUT
             if isnull(@Temp,'''')<>isnull(@TempOLD,'''')
             begin
               if @First=1 
               begin
                 insert into '+ @TableName+@PostfixTable +'(type,'+@IndexName+')
                 values (0,@K)
                 set @KD=SCOPE_IDENTITY()
                 set @First=0
               end
               insert into '+ @TableName+@PostfixTable+'DET (ISPR,FieldName,Old_value,New_Value)
               values (@KD,@FieldName,@TempOLD,@Temp) 
             end
             
          fetch next from @CURSOR into @FieldName
        end
        Close @CURSOR
        deallocate @CURSOR  end'
              
      --select @TN
      EXECUTE (@TN);
      --set @KolError=1
      if @@Error<>0 set @KolError=@KolError + 1024
    
    if @KolError = 0 
    begin
      SELECT 'Журналирование таблицы '+@TableName+' создано';     
      COMMIT;
    end  
    else
    begin
      SELECT 'Ошибка создания логирования ' + @KolError; 
      ROLLBACK;
    end
    /*else SELECT 'Журналирование таблицы '+@TableName+' уже существует'; */

end