CREATE TABLE [dbo].[DailySaldoBR] (
    [ND]      DATETIME NULL,
    [B_ID]    INT      NULL,
    [Debt]    MONEY    NULL,
    [Overdue] MONEY    NULL,
    [Deep]    INT      DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [DailySaldoBR_idx2]
    ON [dbo].[DailySaldoBR]([B_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [DailySaldoBR_idx]
    ON [dbo].[DailySaldoBR]([ND] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Макс.глубина просрочки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DailySaldoBR', @level2type = N'COLUMN', @level2name = N'Deep';

