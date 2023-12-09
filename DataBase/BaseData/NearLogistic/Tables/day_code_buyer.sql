CREATE TABLE [NearLogistic].[day_code_buyer] (
    [dcbID]    INT      IDENTITY (1, 1) NOT NULL,
    [b_id]     INT      NOT NULL,
    [nd]       DATETIME DEFAULT (CONVERT([varchar],getdate(),(104))) NOT NULL,
    [liter_id] INT      DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [day_code_buyer_pk] PRIMARY KEY CLUSTERED ([dcbID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [day_code_buyer_idx2]
    ON [NearLogistic].[day_code_buyer]([nd] ASC);


GO
CREATE NONCLUSTERED INDEX [day_code_buyer_idx]
    ON [NearLogistic].[day_code_buyer]([b_id] ASC);

