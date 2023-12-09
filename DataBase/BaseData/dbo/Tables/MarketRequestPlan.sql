CREATE TABLE [dbo].[MarketRequestPlan] (
    [id]    INT IDENTITY (1, 1) NOT NULL,
    [mrid]  INT NULL,
    [pin]   INT NULL,
    [sv_id] INT NULL,
    [ag_id] INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

