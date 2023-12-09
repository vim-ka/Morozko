CREATE TABLE [dbo].[exite_orderDet] (
    [id]                INT             IDENTITY (1, 1) NOT NULL,
    [OrderID]           INT             NOT NULL,
    [PositionNumber]    INT             NOT NULL,
    [ProductBarcode]    VARCHAR (80)    NULL,
    [SupplierProductID] VARCHAR (80)    NULL,
    [BuyerProductID]    VARCHAR (80)    NULL,
    [OrderedQuantity]   DECIMAL (10, 3) NOT NULL,
    [QuantityInUnit]    INT             NULL,
    [OrderUnit]         VARCHAR (10)    NULL,
    [OrderPrice]        MONEY           NULL,
    [PriceWithVAT]      MONEY           NULL,
    [OrderPriceUnit]    VARCHAR (3)     NULL,
    [VAT]               MONEY           NULL,
    [Description]       VARCHAR (250)   NULL,
    [SendedQuantity]    DECIMAL (10, 3) NULL,
    [RecivedQuantity]   DECIMAL (10, 3) NULL,
    [Line_ID]           VARCHAR (150)   NULL,
    [OKEI]              INT             NULL,
    [ConfirmedQuantity] DECIMAL (10, 3) DEFAULT ((0)) NULL,
    CONSTRAINT [exite_orderDet_pk] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [exite_orderDet_fk] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[exite_orders] ([id]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [exite_orderDet_idx]
    ON [dbo].[exite_orderDet]([OrderID] ASC) WITH (ALLOW_PAGE_LOCKS = OFF);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Подтвержденное кол-во', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'ConfirmedQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код ед. изм по ОКЕЙ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'OKEI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код строчки в заказе (Лукойл)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'Line_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во доставленного покупателю', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'RecivedQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во отгруженного со склада', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'SendedQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'описание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'VAT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'единицы измерения цены', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'OrderPriceUnit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена с НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'PriceWithVAT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена продукта без НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'OrderPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'единицы измерения кол-ва товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'OrderUnit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во в упаковке', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'QuantityInUnit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'заказанное кол-во', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'OrderedQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'внутренний номер бд покупателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'BuyerProductID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'внутренний номер бд поставщика
hitag', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'SupplierProductID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'штрих код', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'ProductBarcode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер товарной позиции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'exite_orderDet', @level2type = N'COLUMN', @level2name = N'PositionNumber';

