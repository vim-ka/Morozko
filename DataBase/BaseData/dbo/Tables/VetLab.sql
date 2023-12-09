CREATE TABLE [dbo].[VetLab] (
    [LabNom]  INT          IDENTITY (1, 1) NOT NULL,
    [LabName] VARCHAR (40) NULL,
    [Nm]      VARCHAR (10) NULL,
    [ND]      DATETIME     NULL,
    [Res]     VARCHAR (20) NULL,
    [Mrk]     VARCHAR (15) NULL,
    [Razr]    VARCHAR (25) NULL,
    UNIQUE NONCLUSTERED ([LabNom] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Разрешение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VetLab', @level2type = N'COLUMN', @level2name = N'Razr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Маркировка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VetLab', @level2type = N'COLUMN', @level2name = N'Mrk';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Результат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VetLab', @level2type = N'COLUMN', @level2name = N'Res';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VetLab', @level2type = N'COLUMN', @level2name = N'ND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер лабораторных исследований', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VetLab', @level2type = N'COLUMN', @level2name = N'Nm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование лаборатории', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VetLab', @level2type = N'COLUMN', @level2name = N'LabName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Уникальный код лабороторных исследований', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VetLab', @level2type = N'COLUMN', @level2name = N'LabNom';

