CREATE TABLE [MobAgents].[OrderTypes] (
    [otk]                INT          IDENTITY (1, 1) NOT NULL,
    [Ident]              VARCHAR (40) NULL,
    [TypeName]           VARCHAR (50) NULL,
    [Order]              INT          NULL,
    [Rest]               SMALLINT     NULL,
    [flgAllowBaseUnit]   CHAR (1)     NULL,
    [flgAllowZeroCount]  CHAR (1)     NULL,
    [flgNoSaleStatistic] CHAR (1)     NULL,
    [printname]          VARCHAR (50) DEFAULT ('') NOT NULL,
    UNIQUE NONCLUSTERED ([otk] ASC)
);

