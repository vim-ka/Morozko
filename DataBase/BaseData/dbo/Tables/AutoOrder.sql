CREATE TABLE [dbo].[AutoOrder] (
    [ND]      DATETIME   NULL,
    [b_id]    INT        NULL,
    [Hitag]   INT        NULL,
    [Qty]     FLOAT (53) NULL,
    [QtyAdd]  FLOAT (53) NULL,
    [Prognoz] FLOAT (53) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Прогноз', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AutoOrder', @level2type = N'COLUMN', @level2name = N'Prognoz';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Добавлено', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AutoOrder', @level2type = N'COLUMN', @level2name = N'QtyAdd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во в заказе', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AutoOrder', @level2type = N'COLUMN', @level2name = N'Qty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AutoOrder', @level2type = N'COLUMN', @level2name = N'Hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код контрагента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AutoOrder', @level2type = N'COLUMN', @level2name = N'b_id';

