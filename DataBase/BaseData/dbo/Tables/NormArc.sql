CREATE TABLE [dbo].[NormArc] (
    [Nd]      DATETIME       NULL,
    [pin]     INT            NOT NULL,
    [IceNorm] MONEY          NULL,
    [PfNorm]  MONEY          NULL,
    [SkipIce] DATETIME       NULL,
    [SkipPf]  DATETIME       NULL,
    [Zarp]    DECIMAL (8, 2) NULL,
    [SumFriz] BIT            NULL
);

