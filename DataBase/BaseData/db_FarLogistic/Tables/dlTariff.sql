CREATE TABLE [db_FarLogistic].[dlTariff] (
    [dateBegin]  DATETIME NULL,
    [Cost]       MONEY    NULL,
    [dlTariffID] INT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [dlTariff_pk] PRIMARY KEY CLUSTERED ([dlTariffID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTariff', @level2type = N'COLUMN', @level2name = N'Cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата начала действия', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTariff', @level2type = N'COLUMN', @level2name = N'dateBegin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица для хранения тарифов грузоперевозок за 1 км пройденного пути', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTariff';

