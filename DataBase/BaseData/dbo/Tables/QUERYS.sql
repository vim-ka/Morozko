CREATE TABLE [dbo].[QUERYS] (
    [ID]       INT  NULL,
    [SQL_TEXT] TEXT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тело запроса', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUERYS', @level2type = N'COLUMN', @level2name = N'SQL_TEXT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор запрос', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUERYS', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица запросов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'QUERYS';

