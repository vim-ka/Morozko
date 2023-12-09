CREATE TABLE [RetroB].[rb_RawDet] (
    [rdetID] INT             IDENTITY (1, 1) NOT NULL,
    [rawID]  INT             NULL,
    [vedID]  INT             NULL,
    [rbID]   INT             NULL,
    [Bonus]  DECIMAL (15, 7) NULL,
    PRIMARY KEY CLUSTERED ([rdetID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [rb_RawDet_idx3]
    ON [RetroB].[rb_RawDet]([rbID] ASC);


GO
CREATE NONCLUSTERED INDEX [rb_RawDet_idx2]
    ON [RetroB].[rb_RawDet]([vedID] ASC);


GO
CREATE NONCLUSTERED INDEX [rb_RawDet_idx]
    ON [RetroB].[rb_RawDet]([rawID] ASC);

