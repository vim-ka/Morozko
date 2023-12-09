CREATE TABLE [warehouse].[stocktaking_audit] (
    [staID]    INT             IDENTITY (1, 1) NOT NULL,
    [detailID] INT             NOT NULL,
    [nd]       DATETIME        DEFAULT (getdate()) NOT NULL,
    [op]       INT             NOT NULL,
    [spk]      INT             NOT NULL,
    [qty]      INT             DEFAULT ((0)) NOT NULL,
    [mass]     DECIMAL (15, 4) DEFAULT ((0)) NOT NULL,
    [cost]     DECIMAL (15, 4) DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([staID] ASC)
);

