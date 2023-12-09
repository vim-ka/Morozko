CREATE TABLE [db_FarLogistic].[dlMarshSheet] (
    [MarshID]  INT           NULL,
    [DateCtrl] DATETIME      NULL,
    [Tr00_02]  VARCHAR (200) NULL,
    [Tr02_04]  VARCHAR (200) NULL,
    [Tr04_06]  VARCHAR (200) NULL,
    [Tr06_08]  VARCHAR (200) NULL,
    [Tr08_10]  VARCHAR (200) NULL,
    [Tr12_14]  VARCHAR (200) NULL,
    [Tr14_16]  VARCHAR (200) NULL,
    [Tr10_12]  VARCHAR (200) NULL,
    [Tr18_20]  VARCHAR (200) NULL,
    [Tr16_18]  VARCHAR (200) NULL,
    [Tr20_22]  VARCHAR (200) NULL,
    [Tr22_00]  VARCHAR (200) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr22_00';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr20_22';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr16_18';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr18_20';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr10_12';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr14_16';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr12_14';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr08_10';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr06_08';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr04_06';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr02_04';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Временной отрезок с 00 до 02 часов', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'Tr00_02';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Контрольная дата', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'DateCtrl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ид маршрута', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet', @level2type = N'COLUMN', @level2name = N'MarshID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица График Движения', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlMarshSheet';

