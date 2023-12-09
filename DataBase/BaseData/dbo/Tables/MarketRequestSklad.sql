CREATE TABLE [dbo].[MarketRequestSklad] (
    [id]       INT IDENTITY (1, 1) NOT NULL,
    [mrid]     INT NULL,
    [skladnum] INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

