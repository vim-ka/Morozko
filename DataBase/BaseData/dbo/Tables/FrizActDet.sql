CREATE TABLE [dbo].[FrizActDet] (
    [DetID]    INT      IDENTITY (1, 1) NOT NULL,
    [ActID]    INT      NULL,
    [Nom]      INT      NULL,
    [B_ID]     INT      NULL,
    [ScanDate] DATETIME NULL,
    [Dck]      INT      NULL,
    UNIQUE NONCLUSTERED ([DetID] ASC)
);

