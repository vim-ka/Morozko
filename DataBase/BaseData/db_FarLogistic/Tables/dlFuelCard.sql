CREATE TABLE [db_FarLogistic].[dlFuelCard] (
    [IDVeh]        INT      NULL,
    [IDCard]       INT      NULL,
    [CardType]     INT      NULL,
    [dtBegin]      DATETIME NULL,
    [dtEnd]        DATETIME NULL,
    [IDFuelHandle] INT      NULL,
    [ID]           INT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [dlFuelCard_pk] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Владелец заправки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlFuelCard', @level2type = N'COLUMN', @level2name = N'IDFuelHandle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата окончания', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlFuelCard', @level2type = N'COLUMN', @level2name = N'dtEnd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата начала', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlFuelCard', @level2type = N'COLUMN', @level2name = N'dtBegin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип карты', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlFuelCard', @level2type = N'COLUMN', @level2name = N'CardType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ карты', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlFuelCard', @level2type = N'COLUMN', @level2name = N'IDCard';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код машины', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlFuelCard', @level2type = N'COLUMN', @level2name = N'IDVeh';

