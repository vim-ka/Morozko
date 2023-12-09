CREATE TABLE [dbo].[MarketRequestFin] (
    [id]   INT            IDENTITY (1, 1) NOT NULL,
    [mrid] INT            NULL,
    [p_id] INT            NULL,
    [perc] NUMERIC (5, 2) DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

