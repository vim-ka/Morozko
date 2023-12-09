CREATE TABLE [dbo].[PremRequestStat] (
    [id]   INT           IDENTITY (1, 1) NOT NULL,
    [name] VARCHAR (128) NULL,
    [ord]  INT           NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tip 0 - обычный бюджет
tip 1 - бюджет по превышениям
tip 2 - бюджет компенсации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PremRequestStat';

