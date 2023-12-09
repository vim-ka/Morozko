CREATE TABLE [db_FarLogistic].[dlControlState] (
    [IDControlState] INT          NULL,
    [Name]           VARCHAR (20) NULL,
    [SName]          VARCHAR (2)  NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlControlState', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlControlState', @level2type = N'COLUMN', @level2name = N'IDControlState';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица проверок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlControlState';

