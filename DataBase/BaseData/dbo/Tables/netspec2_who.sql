CREATE TABLE [dbo].[netspec2_who] (
    [nmid]     INT     NULL,
    [Code]     INT     NULL,
    [CodeTip]  TINYINT NULL,
    [ContrTip] TINYINT DEFAULT ((0)) NULL,
    [htid]     INT     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [netspec2_who_pk_netspec2_who] PRIMARY KEY CLUSTERED ([htid] ASC),
    CONSTRAINT [netspec2_who_fk_netspec2_who] FOREIGN KEY ([nmid]) REFERENCES [dbo].[netspec2_main] ([nmid]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [netspec2_who_idx4]
    ON [dbo].[netspec2_who]([nmid] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_who_idx3]
    ON [dbo].[netspec2_who]([ContrTip] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_who_idx2]
    ON [dbo].[netspec2_who]([CodeTip] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_who_idx]
    ON [dbo].[netspec2_who]([Code] ASC);


GO

CREATE TRIGGER [dbo].[trg_netspec2_who_u]  ON [dbo].[netspec2_who]
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE, DELETE
AS
      begin
        declare @K int, @KD int, @FieldName varchar(50), @Temp sql_variant, @TempOLD sql_variant, @First bit
        declare @TN nvarchar(500)
        DECLARE @ParmDefinition nvarchar(500)
        set @First=1
        Declare @CURSOR Cursor  

        set @CURSOR  = Cursor scroll
        for select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS
        where TABLE_NAME ='netspec2_who' and TABLE_SCHEMA='dbo'     
        open @CURSOR
        

        
        select 0 as nom,i.* into #TempTable from inserted i inner join inserted i1 on i.htid=i1.htid
        
        insert into #TempTable select 1 as nom,* from deleted

        fetch next from @CURSOR into @FieldName


        while @@FETCH_STATUS = 0
        begin
        
             set @K=(select htid from deleted);
             if @K is null set @K=(select htid from inserted);
            
             SET @ParmDefinition = N'@Temp1 sql_variant OUTPUT';
             set @TN=N'set @Temp1=(select '+@FieldName+' from #TempTable where Nom=0)'
             EXEC sp_executeSQL @TN, @ParmDefinition, @Temp1=@Temp OUTPUT
             
             SET @ParmDefinition = N'@TempOLD1 sql_variant OUTPUT';
             set @TN=N'set @TempOLD1=(select '+@FieldName+' from #TempTable where Nom=1)'
             EXEC sp_executeSQL @TN, @ParmDefinition, @TempOLD1=@TempOLD OUTPUT
             if isnull(@Temp,'')<>isnull(@TempOLD,'')
             begin
               if @First=1 
               begin
                 insert into netspec2_whoLog(type,htid)
                 values (0,@K)
                 set @KD=SCOPE_IDENTITY()
                 set @First=0
               end
               insert into netspec2_whoLogDET (ISPR,FieldName,Old_value,New_Value)
               values (@KD,@FieldName,@TempOLD,@Temp) 
             end
             
          fetch next from @CURSOR into @FieldName
        end
        Close @CURSOR
        deallocate @CURSOR  end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0:Все покупатели, 1:Pin означает область, 2:район, 3:отдел, 4:формат, 5:суперв., 6:агент 7: сеть 8:клиент', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec2_who', @level2type = N'COLUMN', @level2name = N'CodeTip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД сущности, см. ниже', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec2_who', @level2type = N'COLUMN', @level2name = N'Code';

