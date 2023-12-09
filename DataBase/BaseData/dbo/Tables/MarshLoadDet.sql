CREATE TABLE [dbo].[MarshLoadDet] (
    [mld] INT IDENTITY (1, 1) NOT NULL,
    [spk] INT NULL,
    [ml]  INT NULL,
    UNIQUE NONCLUSTERED ([mld] ASC)
);

