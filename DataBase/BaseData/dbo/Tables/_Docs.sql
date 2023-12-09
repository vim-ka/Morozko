CREATE TABLE [dbo].[_Docs] (
    [id]      BIGINT   IDENTITY (1, 1) NOT NULL,
    [type]    SMALLINT NULL,
    [prgcode] TINYINT  NULL,
    [nd]      DATETIME DEFAULT (getdate()) NULL,
    [code]    INT      NULL,
    [parent]  BIGINT   NULL,
    [stat]    TINYINT  DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тестовая таблица для Шамана', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'_Docs';

