CREATE TABLE [dbo].[CoefDistanseDel] (
    [cdId]     INT        IDENTITY (1, 1) NOT NULL,
    [CoefDist] INT        NULL,
    [Distanse] FLOAT (53) NULL,
    [Extra]    FLOAT (53) CONSTRAINT [DF__CoefDist__Extra__3E3E00C9] DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([cdId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'% наценки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoefDistanseDel', @level2type = N'COLUMN', @level2name = N'Extra';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дальность', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoefDistanseDel', @level2type = N'COLUMN', @level2name = N'Distanse';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Коэффициент', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoefDistanseDel', @level2type = N'COLUMN', @level2name = N'CoefDist';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица коэф. дальности для агентов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoefDistanseDel';

