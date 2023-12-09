CREATE TABLE [dbo].[DefTags] (
    [deftagID]       INT           IDENTITY (1, 1) NOT NULL,
    [ID]             INT           NULL,
    [TagID]          INT           NULL,
    [TagValue]       SQL_VARIANT   NULL,
    [TagValueString] VARCHAR (255) NULL,
    [OP]             INT           NULL,
    [Comp]           VARCHAR (30)  NULL,
    [ND]             DATETIME      NULL,
    CONSTRAINT [PK__deftagID__0971CCFDD9] PRIMARY KEY CLUSTERED ([deftagID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [DefTags_idx2]
    ON [dbo].[DefTags]([TagID] ASC);


GO
CREATE NONCLUSTERED INDEX [DefTags_idx]
    ON [dbo].[DefTags]([ID] ASC);

