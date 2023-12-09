CREATE TABLE [dbo].[ArcSK] (
    [recn]      INT        IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME   NULL,
    [TekID]     INT        NULL,
    [StartID]   INT        NULL,
    [Pin]       INT        NULL,
    [Hitag]     INT        NULL,
    [Sklad]     TINYINT    NULL,
    [Start]     FLOAT (53) NULL,
    [StartThis] FLOAT (53) NULL,
    [Morn]      FLOAT (53) NULL,
    [Sell]      FLOAT (53) NULL,
    [Price]     FLOAT (53) NULL,
    [Cost]      FLOAT (53) NULL,
    [Minp]      INT        NULL,
    [mpu]       INT        NULL,
    [weight]    FLOAT (53) NULL,
    PRIMARY KEY CLUSTERED ([recn] ASC)
);


GO
CREATE NONCLUSTERED INDEX [DayPinIndex]
    ON [dbo].[ArcSK]([ND] ASC, [Pin] ASC);


GO
CREATE NONCLUSTERED INDEX [DayTekidIndex]
    ON [dbo].[ArcSK]([ND] ASC, [TekID] ASC);


GO
CREATE NONCLUSTERED INDEX [DayHitagIndex]
    ON [dbo].[ArcSK]([ND] ASC, [Hitag] ASC);

