CREATE TABLE [dbo].[MarketRequestDeps] (
    [id]      INT IDENTITY (1, 1) NOT NULL,
    [mrid]    INT NULL,
    [depid]   INT NULL,
    [checked] BIT DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

