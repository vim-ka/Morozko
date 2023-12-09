CREATE TABLE [dbo].[TagsRules] (
    [tagsrulesID] INT IDENTITY (1, 1) NOT NULL,
    [TagID]       INT NULL,
    [EntID]       INT NULL,
    [isFixed]     BIT DEFAULT ((0)) NULL,
    [isReq]       BIT NULL,
    CONSTRAINT [PK__tagsrulesID__0971CCFDD9] PRIMARY KEY CLUSTERED ([tagsrulesID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тэг обязательный', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TagsRules', @level2type = N'COLUMN', @level2name = N'isReq';

