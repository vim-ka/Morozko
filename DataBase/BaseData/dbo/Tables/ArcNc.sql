CREATE TABLE [dbo].[ArcNc] (
    [ncid]   INT          IDENTITY (1, 1) NOT NULL,
    [ND]     DATETIME     NULL,
    [Nnak]   INT          NULL,
    [B_ID]   INT          NULL,
    [Fam]    VARCHAR (30) NULL,
    [SP]     MONEY        NULL,
    [SC]     MONEY        NULL,
    [Fact]   MONEY        NULL,
    [Tara]   TINYINT      DEFAULT (0) NULL,
    [Frizer] INT          DEFAULT (0) NULL,
    [Actn]   TINYINT      DEFAULT (0) NULL,
    [Ice]    TINYINT      DEFAULT (0) NULL,
    [Srok]   INT          DEFAULT (7) NULL,
    [Extra]  NUMERIC (1)  DEFAULT (0) NULL,
    PRIMARY KEY CLUSTERED ([ncid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ArcNcBID]
    ON [dbo].[ArcNc]([B_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [ArcNcNnak]
    ON [dbo].[ArcNc]([Nnak] ASC);


GO
CREATE NONCLUSTERED INDEX [ArcNcDay]
    ON [dbo].[ArcNc]([ND] ASC);

