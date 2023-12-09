CREATE TABLE [dbo].[MarketRequestPrepared] (
    [mrid] INT NULL,
    [b_id] INT NULL
);


GO
CREATE NONCLUSTERED INDEX [mrp_b_id_idx]
    ON [dbo].[MarketRequestPrepared]([b_id] ASC);


GO
CREATE NONCLUSTERED INDEX [mrp_mrid_idx]
    ON [dbo].[MarketRequestPrepared]([mrid] ASC);

