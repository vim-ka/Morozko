CREATE TABLE [dbo].[ArcNv] (
    [nvid]  INT        IDENTITY (1, 1) NOT NULL,
    [ncid]  INT        NULL,
    [tekid] INT        NULL,
    [Kol]   FLOAT (53) NULL,
    [Kol_B] FLOAT (53) NULL,
    [Cost]  MONEY      NULL,
    [Price] MONEY      NULL,
    [sklad] TINYINT    NULL,
    PRIMARY KEY CLUSTERED ([nvid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NcTekid_index]
    ON [dbo].[ArcNv]([ncid] ASC, [tekid] ASC);

