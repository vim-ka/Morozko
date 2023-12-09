CREATE TABLE [dbo].[InmarkoNomen] (
    [CodeNum]    VARCHAR (10)    NOT NULL,
    [Name]       VARCHAR (120)   NULL,
    [NDS]        TINYINT         NULL,
    [Weight]     NUMERIC (10, 5) NULL,
    [MinP]       INT             NULL,
    [BaseUnit]   VARCHAR (5)     NULL,
    [Hitag]      INT             NOT NULL,
    [CodeNumOld] VARCHAR (10)    NULL,
    UNIQUE NONCLUSTERED ([CodeNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код в Nomen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InmarkoNomen', @level2type = N'COLUMN', @level2name = N'Hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Единица измерения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InmarkoNomen', @level2type = N'COLUMN', @level2name = N'BaseUnit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'МинП', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InmarkoNomen', @level2type = N'COLUMN', @level2name = N'MinP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InmarkoNomen', @level2type = N'COLUMN', @level2name = N'Weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InmarkoNomen', @level2type = N'COLUMN', @level2name = N'NDS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InmarkoNomen', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Артикул Инмарко', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InmarkoNomen', @level2type = N'COLUMN', @level2name = N'CodeNum';

