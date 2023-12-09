CREATE TABLE [dbo].[tempRestKassa] (
    [trk]    INT          IDENTITY (1, 1) NOT NULL,
    [pin]    INT          NULL,
    [dck]    INT          NULL,
    [DocNum] VARCHAR (50) NULL,
    [nd]     DATETIME     NULL,
    [sm]     MONEY        NULL,
    [Done]   BIT          DEFAULT ((0)) NOT NULL,
    UNIQUE NONCLUSTERED ([trk] ASC)
);

