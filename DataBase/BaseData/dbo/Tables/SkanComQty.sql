CREATE TABLE [dbo].[SkanComQty] (
    [recId] INT      IDENTITY (1, 1) NOT NULL,
    [odid]  INT      NULL,
    [skg]   SMALLINT NULL,
    [Kol]   INT      NULL,
    [OrdId] INT      NULL,
    PRIMARY KEY CLUSTERED ([recId] ASC)
);

