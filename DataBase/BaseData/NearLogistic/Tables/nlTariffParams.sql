CREATE TABLE [NearLogistic].[nlTariffParams] (
    [nlTariffParamsID] INT   IDENTITY (1, 1) NOT NULL,
    [Pay1Km]           MONEY NULL,
    [Pay1Dot]          MONEY NULL,
    [Pay1Kg]           MONEY NULL,
    [Pay1DotNet]       MONEY NULL,
    [Pay1DotOver]      MONEY NULL,
    [PayAllDot]        MONEY NULL,
    [PayAllDotOver]    MONEY NULL,
    [Rate0Rank]        MONEY NULL,
    [Rate1Rank]        MONEY NULL,
    [Rate2Rank]        MONEY NULL,
    [Rate3Rank]        MONEY NULL,
    [Trailer]          MONEY NULL,
    [Bonus]            MONEY CONSTRAINT [DF__nlTariffP__Bonus__213ADB23_copy] DEFAULT ((0)) NULL,
    [Pay1Hour]         MONEY CONSTRAINT [DF__nlTariffP__Pay1H__7AD60670_copy] DEFAULT ((0)) NOT NULL,
    UNIQUE NONCLUSTERED ([nlTariffParamsID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 часа', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Pay1Hour';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Премия за выполнение всего рейса (25 и более точек)', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Bonus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата за прицеп', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Trailer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата за 3 разряд', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Rate3Rank';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата за 2 разряд', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Rate2Rank';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата за 1 разряд', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Rate1Rank';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата за 0 разряд', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Rate0Rank';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата всех точек свыше 25', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'PayAllDotOver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата всех точек', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'PayAllDot';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 точки свыше 25', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Pay1DotOver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 сетевой точки', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Pay1DotNet';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 кг', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Pay1Kg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 точки', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Pay1Dot';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 км', @level0type = N'SCHEMA', @level0name = N'NearLogistic', @level1type = N'TABLE', @level1name = N'nlTariffParams', @level2type = N'COLUMN', @level2name = N'Pay1Km';

