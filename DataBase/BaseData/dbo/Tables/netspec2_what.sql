CREATE TABLE [dbo].[netspec2_what] (
    [whid]          INT             IDENTITY (1, 1) NOT NULL,
    [nmid]          INT             NULL,
    [Code]          INT             NULL,
    [CodeTip]       TINYINT         NULL,
    [Rez]           DECIMAL (15, 5) NULL,
    [RezTip]        TINYINT         NULL,
    [isWeightPrice] BIT             DEFAULT ((0)) NULL,
    [RezMax]        DECIMAL (15, 5) NULL,
    [FondID]        INT             NULL,
    [FgID]          INT             NULL,
    [varnom]        INT             DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([whid] ASC),
    CONSTRAINT [netspec2_what_fk_netspec2_what] FOREIGN KEY ([nmid]) REFERENCES [dbo].[netspec2_main] ([nmid]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [netspec2_what_idx5]
    ON [dbo].[netspec2_what]([isWeightPrice] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_what_idx4]
    ON [dbo].[netspec2_what]([RezTip] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_what_idx3]
    ON [dbo].[netspec2_what]([CodeTip] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_what_idx2]
    ON [dbo].[netspec2_what]([nmid] ASC);


GO
CREATE NONCLUSTERED INDEX [netspec2_what_idx]
    ON [dbo].[netspec2_what]([Code] ASC);


GO

CREATE TRIGGER [dbo].[trg_netspec2_what_u]  ON [dbo].[netspec2_what]
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
  where TABLE_NAME ='netspec2_what' and TABLE_SCHEMA='dbo'     
  open @CURSOR
  

  
  select 0 as nom,i.* into #TempTable from inserted i inner join inserted i1 on i.whid=i1.whid
  
  insert into #TempTable select 1 as nom,* from deleted

  fetch next from @CURSOR into @FieldName

-- PRINT('ПОДГОТОВКА КО ВХОДУ В ЦИКЛ ЧТЕНИЯ ВЫПОЛНЕНА');
  while @@FETCH_STATUS = 0
  begin
    set @K=(select whid from deleted);
    if @k is null set @k=(select whid from inserted);
    
    SET @ParmDefinition = N'@Temp1 sql_variant OUTPUT';
    set @TN=N'set @Temp1=(select '+@FieldName+' from #TempTable where Nom=0)'
-- print('СЕЙЧАС БУДЕТ ВЫЗОВ EXEC sp_executeSQL '+CAST(@TN AS VARCHAR)+', ' +CAST(@ParmDefinition AS VARCHAR)+', @Temp1='+CAST(@Temp AS VARCHAR)+' OUTPUT');
    EXEC sp_executeSQL @TN, @ParmDefinition, @Temp1=@Temp OUTPUT
    
    SET @ParmDefinition = N'@TempOLD1 sql_variant OUTPUT';
    set @TN=N'set @TempOLD1=(select '+@FieldName+' from #TempTable where Nom=1)'
    EXEC sp_executeSQL @TN, @ParmDefinition, @TempOLD1=@TempOLD OUTPUT

    if isnull(@Temp,'')<>isnull(@TempOLD,'')
    begin
     if @First=1 
     begin
       insert into netspec2_whatLog(type,whid)
-- print('ВЫПОЛНЕНА ВСТАВКА В netspec2_whatLog');
       values (0,@K)
       set @KD=SCOPE_IDENTITY()
       set @First=0
     end
     insert into netspec2_whatLogDET (ISPR,FieldName,Old_value,New_Value)
     values (@KD,@FieldName,@TempOLD,@Temp) 
-- print('ВЫПОЛНЕНА ВСТАВКА В netspec2_whatLogDET');
    end
    fetch next from @CURSOR into @FieldName
  end
  Close @CURSOR
  deallocate @CURSOR  
end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер варианта распределения для группы фондов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec2_what', @level2type = N'COLUMN', @level2name = N'varnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ группы фондов в Finplan.FondGroups', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec2_what', @level2type = N'COLUMN', @level2name = N'FgID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Больше не используется', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec2_what', @level2type = N'COLUMN', @level2name = N'FondID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'относится к 1 шт(0) или 1 кг(1)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec2_what', @level2type = N'COLUMN', @level2name = N'isWeightPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0: Rez=наценка, 1:Rez=цена, 2:запрет продажи.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec2_what', @level2type = N'COLUMN', @level2name = N'RezTip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Результат расчета, цена или наценка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec2_what', @level2type = N'COLUMN', @level2name = N'Rez';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0: Code-поставщик, 1:Code=Ngrp категория товара, 2: Code=Hitag', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec2_what', @level2type = N'COLUMN', @level2name = N'CodeTip';

