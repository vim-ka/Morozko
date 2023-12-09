CREATE TABLE [dbo].[InnerNV] (
    [ivid]    INT             IDENTITY (1, 1) NOT NULL,
    [datnom]  INT             NULL,
    [SkOurId] INT             NULL,
    [NcOurId] INT             NULL,
    [TekId]   INT             NULL,
    [Hitag]   INT             NULL,
    [Cost]    DECIMAL (12, 5) NULL,
    [Kol]     INT             NULL,
    PRIMARY KEY CLUSTERED ([ivid] ASC)
);

