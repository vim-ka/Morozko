CREATE TABLE [dbo].[MarketRequestMonthSales] (
    [b_id]          INT             NULL,
    [hitag]         INT             NULL,
    [PrevMonthSale] DECIMAL (10, 2) DEFAULT ((0)) NULL,
    [CurrMonthSale] DECIMAL (10, 2) DEFAULT ((0)) NULL,
    [TodaySale]     DECIMAL (10, 2) DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [mrms_idx]
    ON [dbo].[MarketRequestMonthSales]([b_id] ASC, [hitag] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Продажи сегодня, кг или шт.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestMonthSales', @level2type = N'COLUMN', @level2name = N'TodaySale';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Продажи за текущий месяц, кг или шт, по вчера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestMonthSales', @level2type = N'COLUMN', @level2name = N'CurrMonthSale';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Продажи за предыдущий месяц, кг или шт.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestMonthSales', @level2type = N'COLUMN', @level2name = N'PrevMonthSale';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Товар', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestMonthSales', @level2type = N'COLUMN', @level2name = N'hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Покупатель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestMonthSales', @level2type = N'COLUMN', @level2name = N'b_id';

