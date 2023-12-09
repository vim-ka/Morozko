CREATE TABLE [dbo].[NomenFILES] (
    [hitag]      INT             NULL,
    [NumberFile] INT             NULL,
    [FileData]   VARBINARY (MAX) NULL,
    [extension]  VARCHAR (5)     NULL,
    [FileName]   VARCHAR (50)    NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя файла', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenFILES', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'расширение файла', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenFILES', @level2type = N'COLUMN', @level2name = N'extension';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'файл', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenFILES', @level2type = N'COLUMN', @level2name = N'FileData';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер файла', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenFILES', @level2type = N'COLUMN', @level2name = N'NumberFile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор ноенклатурной единицы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenFILES', @level2type = N'COLUMN', @level2name = N'hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица для хранения изображений номенклатурных единиц', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NomenFILES';

