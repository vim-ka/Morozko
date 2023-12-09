CREATE TABLE [db_FarLogistic].[dlReqGroup] (
    [IDReqGroup] INT          IDENTITY (5, 1) NOT NULL,
    [GroupName]  VARCHAR (20) NULL,
    [Sys]        BIT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([IDReqGroup] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'системная группа', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlReqGroup', @level2type = N'COLUMN', @level2name = N'Sys';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование группы', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlReqGroup', @level2type = N'COLUMN', @level2name = N'GroupName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор группы заявок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlReqGroup', @level2type = N'COLUMN', @level2name = N'IDReqGroup';

