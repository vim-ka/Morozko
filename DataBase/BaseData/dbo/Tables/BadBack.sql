CREATE TABLE [dbo].[BadBack] (
    [nd]        DATETIME       NULL,
    [datnom]    INT            NOT NULL,
    [refdatnom] INT            NULL,
    [OrigSP]    MONEY          NOT NULL,
    [BackSP]    MONEY          NOT NULL,
    [BackExtra] DECIMAL (6, 2) NULL,
    [OrigExtra] DECIMAL (6, 2) NULL
);


GO
CREATE NONCLUSTERED INDEX [BadBack_idx]
    ON [dbo].[BadBack]([datnom] ASC);


GO
CREATE TRIGGER [dbo].[trg_BadBack_u] ON [dbo].[BadBack]
WITH EXECUTE AS CALLER
FOR UPDATE
AS
      begin
        declare @K int, @KD int, @FieldName varchar(50), @Temp sql_variant, @TempOLD sql_variant, @First bit
        set @First=1
        Declare @CURSOR Cursor  
        DECLARE @ParmDefinition nvarchar(500);
        
        set @CURSOR  = Cursor scroll
        for select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS
        where TABLE_NAME ='BadBack' and TABLE_SCHEMA='dbo'    
        open @CURSOR
        
        select 0 as nom,* into #TempTable from inserted
        insert into #TempTable select 1 as nom,* from deleted

        fetch next from @CURSOR into @FieldName
        declare @TN nvarchar(500)

        while @@FETCH_STATUS = 0
        begin
             set @K=(select datnom from deleted)
             
             SET @ParmDefinition = N'@Temp1 sql_variant OUTPUT';
             
             set @TN=N'set @Temp1=(select '+@FieldName+' from #TempTable where Nom=0)'
             EXEC sp_executeSQL @TN, @ParmDefinition, @Temp1=@Temp OUTPUT
             
             SET @ParmDefinition = N'@TempOLD1 sql_variant OUTPUT';
             set @TN=N'set @TempOLD1=(select '+@FieldName+' from #TempTable where Nom=1)'
             EXEC sp_executeSQL @TN, @ParmDefinition, @TempOLD1=@TempOLD OUTPUT
             if @Temp<>@TempOLD
             begin
               if @First=1 
               begin
                 insert into BadBackLOG5(type,datnom)
                 values (0,@K)
                 set @KD=SCOPE_IDENTITY()
                 set @First=0
               end
               insert into BadBackLOG5DET (ISPR,FieldName,Old_value,New_Value)
               values (@KD,@FieldName,@TempOLD,@Temp) 
             end
             
          fetch next from @CURSOR into @FieldName
        end
        Close @CURSOR
        deallocate @CURSOR 
      end