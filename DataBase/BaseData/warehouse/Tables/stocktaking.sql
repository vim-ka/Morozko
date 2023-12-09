CREATE TABLE [warehouse].[stocktaking] (
    [stID]      INT           IDENTITY (1, 1) NOT NULL,
    [stateID]   INT           CONSTRAINT [DF__stocktaki__state__4E4D78BC] DEFAULT ((1)) NOT NULL,
    [plID]      INT           DEFAULT ((1)) NOT NULL,
    [nd_create] DATETIME      DEFAULT (getdate()) NOT NULL,
    [nd_close]  DATETIME      DEFAULT (NULL) NULL,
    [op]        INT           NOT NULL,
    [remark]    VARCHAR (200) DEFAULT ('') NOT NULL,
    PRIMARY KEY CLUSTERED ([stID] ASC)
);

