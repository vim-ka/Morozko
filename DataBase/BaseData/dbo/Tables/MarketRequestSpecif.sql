CREATE TABLE [dbo].[MarketRequestSpecif] (
    [id]   INT IDENTITY (1, 1) NOT NULL,
    [mrid] INT NULL,
    [nmid] INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

