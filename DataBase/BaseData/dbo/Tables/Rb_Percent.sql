CREATE TABLE [dbo].[Rb_Percent] (
    [RbID]   INT             NULL,
    [Level0] DECIMAL (12, 2) NULL,
    [Level1] DECIMAL (12, 2) NULL,
    [Perc]   DECIMAL (12, 2) NULL
);


GO
CREATE NONCLUSTERED INDEX [Rb_Percent_idx]
    ON [dbo].[Rb_Percent]([RbID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'При попадании оплаты в диапазон [Level0, Level1) будет начислен процент Perc от суммы.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Rb_Percent', @level2type = N'COLUMN', @level2name = N'Perc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Верхний порог продаж (или оплаты)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Rb_Percent', @level2type = N'COLUMN', @level2name = N'Level1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Нижний порог продаж (или оплаты)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Rb_Percent', @level2type = N'COLUMN', @level2name = N'Level0';

