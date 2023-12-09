CREATE TABLE [Statistics].[SExtType] (
    [id]   INT          IDENTITY (1, 1) NOT NULL,
    [name] VARCHAR (64) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица типов статистик: кг, шт., проценты и т.д.', @level0type = N'SCHEMA', @level0name = N'Statistics', @level1type = N'TABLE', @level1name = N'SExtType';

