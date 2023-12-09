CREATE TABLE [dbo].[VendOrder] (
    [Hitag]         INT        NULL,
    [SPrice]        MONEY      NULL,
    [SCost]         MONEY      NULL,
    [Month2]        FLOAT (53) NULL,
    [Month1]        FLOAT (53) NULL,
    [CurrMonth]     FLOAT (53) NULL,
    [AvgTempSale]   FLOAT (53) NULL,
    [DCK]           INT        DEFAULT ((0)) NULL,
    [DOstMonth1]    INT        DEFAULT ((0)) NULL,
    [DOstCurrMonth] INT        DEFAULT ((0)) NULL,
    [PLID]          INT        NULL,
    [pin]           INT        NULL
);


GO
CREATE NONCLUSTERED INDEX [VendOrder_idx5]
    ON [dbo].[VendOrder]([PLID] ASC);


GO
CREATE NONCLUSTERED INDEX [VendOrder_idx4]
    ON [dbo].[VendOrder]([Hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [VendOrder_idx3]
    ON [dbo].[VendOrder]([DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [VendOrder_idx]
    ON [dbo].[VendOrder]([pin] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [VendOrder_uq]
    ON [dbo].[VendOrder]([Hitag] ASC, [DCK] ASC, [pin] ASC, [PLID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Местонахождение складов (SkladPlace)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'PLID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во дней, когда остаток присутствовал', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'DOstCurrMonth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во дней, когда остаток присутствовал', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'DOstMonth1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'темп продаж дневной', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'AvgTempSale';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'продажи текущий месяц', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'CurrMonth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'продажи - 1 мес.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'Month1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'продажи - 2 мес.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'Month2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'средняя цена закупки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'SCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'средняя цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'SPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendOrder', @level2type = N'COLUMN', @level2name = N'Hitag';

