CREATE TABLE [db_FarLogistic].[dlLoadingUnit] (
    [dlLoadingUnitID] INT          IDENTITY (3, 1) NOT NULL,
    [Name]            VARCHAR (10) NOT NULL,
    [ShortName]       VARCHAR (3)  NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сокращение', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlLoadingUnit', @level2type = N'COLUMN', @level2name = N'ShortName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlLoadingUnit', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор единицы загрузки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlLoadingUnit', @level2type = N'COLUMN', @level2name = N'dlLoadingUnitID';

