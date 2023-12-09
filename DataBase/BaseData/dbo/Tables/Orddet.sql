CREATE TABLE [dbo].[Orddet] (
    [odid]       INT             IDENTITY (1, 1) NOT NULL,
    [OrdID]      INT             NOT NULL,
    [Hitag]      INT             NULL,
    [Qty]        INT             NULL,
    [Price]      MONEY           DEFAULT ((0)) NULL,
    [Cost]       MONEY           DEFAULT ((0)) NULL,
    [DocQty]     INT             NULL,
    [DocCost]    MONEY           NULL,
    [ScanQty21]  INT             DEFAULT ((0)) NULL,
    [ScanQty27]  INT             DEFAULT ((0)) NULL,
    [ScanQtyOld] INT             DEFAULT ((0)) NULL,
    [ScanQtyNak] INT             DEFAULT ((0)) NULL,
    [NCOM]       INT             DEFAULT ((0)) NULL,
    [Weight]     DECIMAL (12, 3) NULL,
    [Done]       TINYINT         DEFAULT ((0)) NULL,
    [ScanQty28]  INT             DEFAULT ((0)) NULL,
    [ScanQty29]  INT             DEFAULT ((0)) NULL,
    [BarCode]    VARCHAR (20)    NULL,
    [Srokh]      DATETIME        NULL,
    [Dater]      DATETIME        NULL,
    [Country]    VARCHAR (15)    NULL,
    [RecQty]     INT             NULL,
    [LineNo]     INT             NULL,
    [ExtTag]     VARCHAR (20)    NULL,
    PRIMARY KEY CLUSTERED ([odid] ASC),
    CONSTRAINT [Orddet_fk] FOREIGN KEY ([OrdID]) REFERENCES [dbo].[Orders] ([OrdID]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [Orddet_idx]
    ON [dbo].[Orddet]([OrdID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orddet', @level2type = N'COLUMN', @level2name = N'ExtTag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'рекомендовано к заказу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orddet', @level2type = N'COLUMN', @level2name = N'RecQty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'штрих-код товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orddet', @level2type = N'COLUMN', @level2name = N'BarCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во по документу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orddet', @level2type = N'COLUMN', @level2name = N'DocQty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена закупки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orddet', @level2type = N'COLUMN', @level2name = N'Cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orddet', @level2type = N'COLUMN', @level2name = N'Price';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во заказанного', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orddet', @level2type = N'COLUMN', @level2name = N'Qty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orddet', @level2type = N'COLUMN', @level2name = N'Hitag';

