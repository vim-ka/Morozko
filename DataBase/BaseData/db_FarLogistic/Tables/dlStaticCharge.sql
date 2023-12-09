CREATE TABLE [db_FarLogistic].[dlStaticCharge] (
    [date]         INT          NULL,
    [VehID]        INT          NULL,
    [VehTypeID]    INT          NULL,
    [RealDistance] INT          NULL,
    [CalcDistance] INT          NULL,
    [ForPay]       MONEY        NULL,
    [AmortExp]     MONEY        NULL,
    [ServExp]      MONEY        NULL,
    [StrahExp]     MONEY        NULL,
    [FuelExp]      MONEY        NULL,
    [LogExp]       MONEY        NULL,
    [DrvExp]       MONEY        NULL,
    [OtherExp]     MONEY        NULL,
    [DateCreate]   DATETIME     DEFAULT (getdate()) NULL,
    [comp]         VARCHAR (50) DEFAULT (host_name()) NULL,
    [PAmortKM]     MONEY        DEFAULT ((0)) NULL,
    [PServKM]      MONEY        NULL,
    [PStrahKM]     MONEY        NULL,
    [PFuelKM]      MONEY        NULL,
    [PDrvKM]       MONEY        NULL,
    [PLogKM]       MONEY        NULL,
    [POtherKM]     MONEY        NULL,
    [PPriceKM]     MONEY        NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [dlStaticCharge_uq]
    ON [db_FarLogistic].[dlStaticCharge]([date] ASC, [VehID] DESC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Прочие', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'OtherExp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Водители', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'DrvExp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логисты', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'LogExp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Топливо', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'FuelExp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Страховка', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'StrahExp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сервис', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'ServExp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Амортизация', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'AmortExp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выручка', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'ForPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Рассчет', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'CalcDistance';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Одометр', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'RealDistance';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИДТипа', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'VehTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИДТранспорта', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'VehID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ГодМесяц', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlStaticCharge', @level2type = N'COLUMN', @level2name = N'date';

