CREATE TABLE [dbo].[ShTypeCode] (
    [Pref]        VARCHAR (5)   NULL,
    [Format]      VARCHAR (20)  NULL,
    [Description] VARCHAR (100) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Формат штрих-кода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShTypeCode', @level2type = N'COLUMN', @level2name = N'Format';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Типы штрихкодов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShTypeCode';

