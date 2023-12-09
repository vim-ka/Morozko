CREATE TABLE [dbo].[DefExclude] (
    [Pin]         INT      NOT NULL,
    [ExcludeType] SMALLINT NULL,
    [ND]          DATETIME DEFAULT (getdate()) NULL,
    [dek]         INT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [DefExclude_pk] PRIMARY KEY CLUSTERED ([dek] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DefExclude_uq]
    ON [dbo].[DefExclude]([Pin] ASC, [ExcludeType] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип исключения
0 - рыба
1 - Done (порог < 1500 руб.)
2 - не разделять накладные', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefExclude', @level2type = N'COLUMN', @level2name = N'ExcludeType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код покупателя, исключаемого из проверки на запрет продажи биржевого товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefExclude', @level2type = N'COLUMN', @level2name = N'Pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Список покупателей, исключаемых из всех списков запрета', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefExclude';

