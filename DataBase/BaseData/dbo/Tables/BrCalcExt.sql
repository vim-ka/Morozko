CREATE TABLE [dbo].[BrCalcExt] (
    [ID]       INT        IDENTITY (1, 1) NOT NULL,
    [B_ID]     INT        NULL,
    [Hitag]    INT        NULL,
    [Price]    MONEY      NULL,
    [Cost]     MONEY      NULL,
    [Kol]      INT        NULL,
    [SetExtra] FLOAT (53) NULL,
    [Tmp]      FLOAT (53) NULL,
    [Ncod]     INT        NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

