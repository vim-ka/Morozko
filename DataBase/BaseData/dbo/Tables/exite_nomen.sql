CREATE TABLE [dbo].[exite_nomen] (
    [id]               INT             IDENTITY (1, 1) NOT NULL,
    [hitag]            INT             NOT NULL,
    [dateAdd]          DATETIME        CONSTRAINT [DF__x5nomen__dateAdd__78FF9F3B] DEFAULT (getdate()) NULL,
    [DateRemove]       DATETIME        NULL,
    [PLU]              VARCHAR (50)    NOT NULL,
    [Fname]            VARCHAR (75)    NULL,
    [DelivQuantum]     SMALLINT        NULL,
    [NDS]              MONEY           NULL,
    [PriceWithNDS]     MONEY           NULL,
    [PriceWithoutNDS]  MONEY           NULL,
    [ActionInPosition] TINYINT         DEFAULT ((2)) NULL,
    [barCode]          VARCHAR (20)    NULL,
    [Weight]           DECIMAL (10, 3) NULL,
    [OrderUnit]        CHAR (3)        NULL,
    [CLID]             SMALLINT        DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [exite_nomen_fk] FOREIGN KEY ([CLID]) REFERENCES [dbo].[Exite_Clients] ([CLID]) ON UPDATE CASCADE
);


GO
ALTER TABLE [dbo].[exite_nomen] NOCHECK CONSTRAINT [exite_nomen_fk];


GO
CREATE UNIQUE NONCLUSTERED INDEX [exite_nomen_uq2]
    ON [dbo].[exite_nomen]([hitag] ASC, [PLU] ASC, [CLID] ASC);


GO
CREATE TRIGGER [dbo].[x5nomen_tru] ON [dbo].[exite_nomen]
WITH EXECUTE AS CALLER
FOR UPDATE
AS
BEGIN
 declare @hitag int, @oldPrice money, @newPrice money,
 		 @oldName varchar(75), @newName varchar(75),
         @DateRemove datetime
 
 select @hitag = hitag, @oldPrice = priceWithNDS, @oldName = fname from deleted
 select @newPrice = priceWithNds, @newName = fname, @DateRemove = dateRemove from INSERTED
 
  if @oldPrice<@newPrice update exite_nomen set ActionInPosition = 5 where hitag = @hitag /* подорожание */
  if @oldPrice>@newPrice update exite_nomen set ActionInPosition = 6 where hitag = @hitag /* подешевление */
  if @oldName<>@newName update exite_nomen set ActionInPosition = 4 where hitag = @hitag /* изменение */
  if @dateRemove is not null update exite_nomen set ActionInPosition = 3 where hitag = @hitag /* удаление */ 
    
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор клиента, см. Exite_Clients', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'CLID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Единица измерения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'OrderUnit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'Weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Штрих-код', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'barCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Действие позиции в прайсе.
2-новое
3-удаление
4-изменение
5-подорожание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'ActionInPosition';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена без НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'PriceWithoutNDS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена с НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'PriceWithNDS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ставка НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'NDS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Квант поставки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'DelivQuantum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'Fname';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код номенклатуры Х5', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'PLU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата удаления', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'DateRemove';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата добавления', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'dateAdd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_nomen', @level2type = N'COLUMN', @level2name = N'hitag';

