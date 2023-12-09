CREATE TABLE [dbo].[ScanSklad3] (
    [id]       INT         IDENTITY (1, 1) NOT NULL,
    [mhid]     INT         NULL,
    [nd]       DATETIME    DEFAULT (getdate()) NULL,
    [tmBeg]    CHAR (8)    NULL,
    [tmEnd]    CHAR (8)    NULL,
    [spk]      INT         NULL,
    [trID]     INT         NULL,
    [skg]      INT         NULL,
    [OP]       INT         NULL,
    [marsh]    INT         NULL,
    [marshnd]  DATETIME    NULL,
    [pref]     VARCHAR (5) NULL,
    [spk_stsm] INT         DEFAULT ((-1)) NULL,
    [qual]     INT         DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ScanSklad3_idx7]
    ON [dbo].[ScanSklad3]([skg] ASC);


GO
CREATE NONCLUSTERED INDEX [ScanSklad3_idx6]
    ON [dbo].[ScanSklad3]([trID] ASC);


GO
CREATE NONCLUSTERED INDEX [ScanSklad3_idx5]
    ON [dbo].[ScanSklad3]([marshnd] ASC);


GO
CREATE NONCLUSTERED INDEX [ScanSklad3_idx4]
    ON [dbo].[ScanSklad3]([marsh] ASC);


GO
CREATE NONCLUSTERED INDEX [ScanSklad3_idx3]
    ON [dbo].[ScanSklad3]([pref] ASC);


GO
CREATE NONCLUSTERED INDEX [ScanSklad3_idx2]
    ON [dbo].[ScanSklad3]([spk] ASC);


GO
CREATE NONCLUSTERED INDEX [ScanSklad3_idx]
    ON [dbo].[ScanSklad3]([mhid] ASC);

