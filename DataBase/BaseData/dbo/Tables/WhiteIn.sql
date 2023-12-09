CREATE TABLE [dbo].[WhiteIn] (
    [ncom]    INT          NULL,
    [nname]   VARCHAR (60) NULL,
    [qty]     FLOAT (53)   NULL,
    [cost]    MONEY        NULL,
    [cost1kg] MONEY        NULL,
    [weight]  FLOAT (53)   NULL,
    [country] VARCHAR (50) CONSTRAINT [DF__WhiteIn__country__37A611D3] DEFAULT ('Россия') NULL,
    [Nds]     TINYINT      NULL,
    [Gtd]     VARCHAR (30) NULL,
    [Units]   VARCHAR (10) NULL,
    [Sklad]   TINYINT      DEFAULT (0) NULL,
    [wk]      INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [WhiteIn_pk] PRIMARY KEY CLUSTERED ([wk] ASC)
);

