CREATE TABLE [dbo].[LockLog] (
    [llid]      INT          IDENTITY (1, 1) NOT NULL,
    [nd]        DATETIME     DEFAULT ([dbo].[today]()) NULL,
    [tm]        CHAR (8)     DEFAULT (CONVERT([time],getdate(),0)) NULL,
    [OP]        INT          NULL,
    [ID]        INT          NULL,
    [Hitag]     INT          NULL,
    [Sklad]     INT          NULL,
    [LockFlag]  TINYINT      CONSTRAINT [DF__LockLog__LockFla__5484A9A8] DEFAULT ((0)) NULL,
    [lrID]      INT          NULL,
    [Remark]    VARCHAR (40) NULL,
    [Dest]      VARCHAR (50) NULL,
    [p_id]      INT          NULL,
    [FinishDay] DATETIME     NULL,
    [Comp]      VARCHAR (30) NULL,
    PRIMARY KEY CLUSTERED ([llid] ASC)
);


GO
CREATE TRIGGER [dbo].[trg_LockLog_u] ON [dbo].[LockLog]
WITH EXECUTE AS CALLER
FOR UPDATE
AS
      begin
        declare @K int, @KD int, @FieldName varchar(50), @Temp sql_variant, @TempOLD sql_variant, @First bit
        declare @TN nvarchar(500)
        DECLARE @ParmDefinition nvarchar(500)
        set @First=1
        Declare @CURSOR Cursor 
        declare @NamePK varchar(100) 

        set @CURSOR  = Cursor scroll
        for select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS
        where TABLE_NAME ='LockLog'     
        open @CURSOR
        
        fetch next from @CURSOR into @FieldName
        
        select 0 as nom,i.* into #TempTable from inserted i inner join inserted i1 on i.llid=i1.llid
       
        insert into #TempTable select 1 as nom,* from deleted  

        while @@FETCH_STATUS = 0
        begin
        
             set @K=(select llid from deleted)
            
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
                 insert into LockLogRec(type,llid)
                 values (0,@K)
                 set @KD=SCOPE_IDENTITY()
                 set @First=0
               end
               insert into LockLogRecDET (ISPR,FieldName,Old_value,New_Value)
               values (@KD,@FieldName,@TempOLD,@Temp) 
             end
             
          fetch next from @CURSOR into @FieldName
        end
        Close @CURSOR
        deallocate @CURSOR  end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Срок действия блокировки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LockLog', @level2type = N'COLUMN', @level2name = N'FinishDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ответственный в Person', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LockLog', @level2type = N'COLUMN', @level2name = N'p_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для кого', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LockLog', @level2type = N'COLUMN', @level2name = N'Dest';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ключ в табл.оснований LockReason', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LockLog', @level2type = N'COLUMN', @level2name = N'lrID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-блокировка, 0-разблокировка,2-продление', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LockLog', @level2type = N'COLUMN', @level2name = N'LockFlag';

