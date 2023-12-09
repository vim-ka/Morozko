CREATE TABLE [Statistics].[SStat] (
    [id]      INT           IDENTITY (1, 1) NOT NULL,
    [exttype] INT           CONSTRAINT [DF__SStat__exttype__31C648A7] DEFAULT ((1)) NULL,
    [name]    VARCHAR (256) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наименование', @level0type = N'SCHEMA', @level0name = N'Statistics', @level1type = N'TABLE', @level1name = N'SStat', @level2type = N'COLUMN', @level2name = N'name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на таблицу вариантов учета', @level0type = N'SCHEMA', @level0name = N'Statistics', @level1type = N'TABLE', @level1name = N'SStat', @level2type = N'COLUMN', @level2name = N'exttype';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица', @level0type = N'SCHEMA', @level0name = N'Statistics', @level1type = N'TABLE', @level1name = N'SStat';

