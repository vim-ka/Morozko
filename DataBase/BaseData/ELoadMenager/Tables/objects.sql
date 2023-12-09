CREATE TABLE [ELoadMenager].[objects] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [ParentID]       INT            DEFAULT ((0)) NOT NULL,
    [Name]           VARCHAR (50)   DEFAULT ('') NOT NULL,
    [Description]    VARCHAR (1000) DEFAULT ('') NOT NULL,
    [Date_publish]   DATETIME       DEFAULT (getdate()) NOT NULL,
    [Date_lastuse]   DATETIME       DEFAULT (getdate()) NOT NULL,
    [Date_lastprint] DATETIME       DEFAULT (getdate()) NOT NULL,
    [isFolder]       BIT            DEFAULT ((0)) NOT NULL,
    [isDel]          BIT            DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [objects_idx2]
    ON [ELoadMenager].[objects]([ParentID] ASC);


GO
CREATE NONCLUSTERED INDEX [objects_idx]
    ON [ELoadMenager].[objects]([Date_publish] ASC);

