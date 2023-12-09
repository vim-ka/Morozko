CREATE TABLE [dbo].[FrizerFuncOborot] (
    [ffob]   INT   IDENTITY (1, 1) NOT NULL,
    [ffid]   INT   NULL,
    [month]  INT   DEFAULT ((0)) NULL,
    [oborot] MONEY NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оборот', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerFuncOborot', @level2type = N'COLUMN', @level2name = N'oborot';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Месяц', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerFuncOborot', @level2type = N'COLUMN', @level2name = N'month';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Назначение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerFuncOborot', @level2type = N'COLUMN', @level2name = N'ffid';

