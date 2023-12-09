CREATE TABLE [dbo].[SkladGroups] (
    [skg]       INT           NOT NULL,
    [skgName]   VARCHAR (30)  NULL,
    [SkladList] VARCHAR (300) NULL,
    [Build]     VARCHAR (1)   NULL,
    [NumSklad]  CHAR (4)      NULL,
    [PLID]      INT           CONSTRAINT [DF__SkladGroup__PLID__58EA3769] DEFAULT ((1)) NOT NULL,
    [Our_ID]    INT           CONSTRAINT [DF__SkladGrou__Our_I__59DE5BA2] DEFAULT ((7)) NOT NULL,
    [srid]      INT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [SkladGroups_pk] PRIMARY KEY CLUSTERED ([skg] ASC),
    CONSTRAINT [SkladGroups_fk] FOREIGN KEY ([PLID]) REFERENCES [dbo].[SkladPlace] ([PLID]) ON UPDATE CASCADE
);

