CREATE TABLE [FinPlan].[fpPeriod] (
    [id]       INT      IDENTITY (1, 1) NOT NULL,
    [datefrom] DATETIME NULL,
    [dateto]   DATETIME NULL,
    [closed]   BIT      DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

