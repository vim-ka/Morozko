CREATE TABLE [dbo].[Entity] (
    [EntId]          INT           IDENTITY (1, 1) NOT NULL,
    [EntName]        VARCHAR (200) NULL,
    [EntDescription] VARCHAR (255) NULL,
    [EntTagsName]    VARCHAR (200) NULL,
    CONSTRAINT [PK__EntID__0971CCFDD9] PRIMARY KEY CLUSTERED ([EntId] ASC)
);

