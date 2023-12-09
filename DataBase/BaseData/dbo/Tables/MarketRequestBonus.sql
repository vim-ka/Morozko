CREATE TABLE [dbo].[MarketRequestBonus] (
    [id]     INT             IDENTITY (1, 1) NOT NULL,
    [mrid]   INT             NULL,
    [hitag]  INT             NULL,
    [price]  NUMERIC (16, 2) DEFAULT ((0)) NULL,
    [slotid] INT             DEFAULT ((-1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

