CREATE TABLE [dbo].[DebugTaraDet] (
    [tdid]    INT     IDENTITY (1, 1) NOT NULL,
    [tarid]   INT     NULL,
    [naktip]  TINYINT DEFAULT (0) NULL,
    [nnak]    INT     NULL,
    [taratip] TINYINT DEFAULT (1) NULL,
    [kol]     INT     NULL,
    [price]   MONEY   NULL,
    PRIMARY KEY CLUSTERED ([tdid] ASC)
);

