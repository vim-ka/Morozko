CREATE TABLE [db_FarLogistic].[dlDefPoint] (
    [IDPointList] INT NULL,
    [pin]         INT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор списка', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDefPoint', @level2type = N'COLUMN', @level2name = N'IDPointList';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'списки загрузки для поставщика', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDefPoint';

