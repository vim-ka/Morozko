CREATE TABLE [dbo].[KsOperStat] (
    [ko]   INT IDENTITY (1, 1) NOT NULL,
    [Oper] INT NULL,
    [StID] INT NULL,
    UNIQUE NONCLUSTERED ([ko] ASC)
);

