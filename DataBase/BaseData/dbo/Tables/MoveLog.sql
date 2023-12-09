CREATE TABLE [dbo].[MoveLog] (
    [MLK]      INT             IDENTITY (1, 1) NOT NULL,
    [ID]       INT             NULL,
    [Rest]     DECIMAL (12, 3) NULL,
    [GoodQty]  INT             NULL,
    [BadQty]   INT             NULL,
    [NewSklad] INT             NULL,
    [Rezerv]   INT             NULL,
    CONSTRAINT [MoveLog_pk] PRIMARY KEY CLUSTERED ([MLK] ASC)
);

