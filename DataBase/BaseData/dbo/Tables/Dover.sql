CREATE TABLE [dbo].[Dover] (
    [DovID]    INT          IDENTITY (1, 1) NOT NULL,
    [DovID2]   INT          NULL,
    [DovNom]   VARCHAR (20) NULL,
    [DovOutID] INT          NULL,
    [Our_ID]   INT          NULL,
    [ag_id]    INT          NULL,
    [ND]       DATETIME     NULL,
    [NDBeg]    DATETIME     NULL,
    [NDEnd]    DATETIME     NULL,
    [NDUse]    DATETIME     NULL,
    [SumUse]   MONEY        NULL,
    [Remark]   VARCHAR (50) NULL,
    [DovStat]  TINYINT      NULL,
    [DCK]      INT          NULL,
    [KassID]   INT          NULL,
    [p_id]     INT          NULL,
    [ScanND]   DATETIME     NULL,
    CONSTRAINT [PK__Dover__4BA6ED898E4DC12F] PRIMARY KEY CLUSTERED ([DovID] ASC),
    CONSTRAINT [Dover_fk] FOREIGN KEY ([DovOutID]) REFERENCES [dbo].[DovOut] ([DovOutID]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [Dover_idx4]
    ON [dbo].[Dover]([DovStat] ASC);


GO
CREATE NONCLUSTERED INDEX [Dover_idx3]
    ON [dbo].[Dover]([p_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Dover_idx2]
    ON [dbo].[Dover]([ag_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Dover_idx]
    ON [dbo].[Dover]([DovStat] ASC);

