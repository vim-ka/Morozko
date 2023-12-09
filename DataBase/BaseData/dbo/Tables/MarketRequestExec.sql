CREATE TABLE [dbo].[MarketRequestExec] (
    [mreID] INT      IDENTITY (1, 1) NOT NULL,
    [ND]    DATETIME DEFAULT ([dbo].[today]()) NULL,
    [AG_ID] INT      NULL,
    [B_ID]  INT      NULL,
    [Mrid]  INT      NULL,
    [Cnt]   SMALLINT NULL,
    PRIMARY KEY CLUSTERED ([mreID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сколько раз фактически выполнена акция (начислена и отгружена)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketRequestExec', @level2type = N'COLUMN', @level2name = N'Mrid';

