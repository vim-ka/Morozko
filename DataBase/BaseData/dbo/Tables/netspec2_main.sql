CREATE TABLE [dbo].[netspec2_main] (
    [nmid]       INT           IDENTITY (1, 1) NOT NULL,
    [StartDate]  DATETIME      NULL,
    [FinishDate] DATETIME      NULL,
    [OP]         INT           NULL,
    [Activ]      BIT           DEFAULT ((1)) NULL,
    [Remark]     VARCHAR (100) NULL,
    [Prior]      TINYINT       DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([nmid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [netspec2_main_idx5]
    ON [dbo].[netspec2_main]([FinishDate] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_main_idx4]
    ON [dbo].[netspec2_main]([StartDate] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_main_idx3]
    ON [dbo].[netspec2_main]([Activ] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_main_idx2]
    ON [dbo].[netspec2_main]([Prior] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_main_idx]
    ON [dbo].[netspec2_main]([OP] ASC);


GO

CREATE TRIGGER [dbo].[trg_netspec2_main_u]  ON [dbo].[netspec2_main]
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE, DELETE
AS
      BEGIN 
        declare @K int, @KD int, @FieldName varchar(50), @Temp sql_variant, @TempOLD sql_variant, @First bit
        declare @TN nvarchar(500)
        DECLARE @ParmDefinition nvarchar(500)
        set @First=1
        Declare @CURSOR Cursor  

        set @CURSOR  = Cursor scroll
        for select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS
        where TABLE_NAME ='netspec2_main' and TABLE_SCHEMA='dbo'     
        open @CURSOR
        

        
        select 0 as nom,i.* into #TempTable from inserted i inner join inserted i1 on i.nmid=i1.nmid
        
        insert into #TempTable select 1 as nom,* from deleted

        fetch next from @CURSOR into @FieldName


        while @@FETCH_STATUS = 0
        begin
        
             set @K=(select nmid from deleted);
             if @K is null set @K=(select nmid from inserted);
            
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
                 insert into netspec2_mainLog(type,nmid)
                 values (0,@K)
                 set @KD=SCOPE_IDENTITY()
                 set @First=0
               end
               insert into netspec2_mainLogDET (ISPR,FieldName,Old_value,New_Value)
               values (@KD,@FieldName,@TempOLD,@Temp) 
             end
             
          fetch next from @CURSOR into @FieldName
        end
        Close @CURSOR
        deallocate @CURSOR  end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приоритет', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec2_main', @level2type = N'COLUMN', @level2name = N'Prior';

