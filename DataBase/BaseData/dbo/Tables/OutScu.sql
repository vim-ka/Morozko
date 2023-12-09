CREATE TABLE [dbo].[OutScu] (
    [recn]  INT           IDENTITY (1, 1) NOT NULL,
    [nd]    SMALLDATETIME NULL,
    [b_id]  INT           NULL,
    [hitag] INT           NULL,
    PRIMARY KEY CLUSTERED ([recn] ASC)
);


GO
CREATE NONCLUSTERED INDEX [OutScu_bid_idx]
    ON [dbo].[OutScu]([b_id] ASC);


GO
CREATE NONCLUSTERED INDEX [OutScu_nd_idx]
    ON [dbo].[OutScu]([nd] ASC);

