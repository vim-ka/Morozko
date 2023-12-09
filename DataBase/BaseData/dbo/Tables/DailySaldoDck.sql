CREATE TABLE [dbo].[DailySaldoDck] (
    [ND]       DATETIME        NULL,
    [B_ID]     INT             NULL,
    [DCK]      INT             DEFAULT ((0)) NULL,
    [Debt]     MONEY           NULL,
    [Overdue]  MONEY           NULL,
    [Deep]     INT             DEFAULT ((0)) NULL,
    [OverUp17] DECIMAL (12, 2) DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [DailySaldoDck_idx3]
    ON [dbo].[DailySaldoDck]([DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [DailySaldoDck_idx2]
    ON [dbo].[DailySaldoDck]([B_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [DailySaldoDck_idx]
    ON [dbo].[DailySaldoDck]([ND] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Просрочка 17 и более дней', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DailySaldoDck', @level2type = N'COLUMN', @level2name = N'OverUp17';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Глубина просрочки в днях', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DailySaldoDck', @level2type = N'COLUMN', @level2name = N'Deep';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Просроченная дебиторская задолженность', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DailySaldoDck', @level2type = N'COLUMN', @level2name = N'Overdue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полная дебиторская задолженность', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DailySaldoDck', @level2type = N'COLUMN', @level2name = N'Debt';

