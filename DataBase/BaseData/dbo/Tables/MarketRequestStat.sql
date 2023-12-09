CREATE TABLE [dbo].[MarketRequestStat] (
    [id]   INT           IDENTITY (1, 1) NOT NULL,
    [name] VARCHAR (128) NULL,
    [ord]  INT           NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

