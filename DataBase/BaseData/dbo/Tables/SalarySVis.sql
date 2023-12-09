CREATE TABLE [dbo].[SalarySVis] (
    [yy]           INT             NULL,
    [mm]           INT             NULL,
    [svid]         INT             NULL,
    [KPremDeb]     DECIMAL (10, 2) DEFAULT ((1500.0)) NULL,
    [PremTT]       DECIMAL (12, 2) NULL,
    [PremAg]       DECIMAL (12, 2) NULL,
    [KPremAg]      DECIMAL (12, 2) DEFAULT ((15)) NULL,
    [Oklad]        DECIMAL (12, 2) DEFAULT ((10000.0)) NULL,
    [Add]          DECIMAL (12, 2) NULL,
    [SPremVen]     DECIMAL (10, 2) DEFAULT ((0)) NULL,
    [PrevMonthPay] DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [POZPM]        DECIMAL (10, 2) DEFAULT ((0)) NULL,
    [CurrMonthPay] DECIMAL (12, 2) DEFAULT ((0)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плата покупателей за расчетный месяц', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SalarySVis', @level2type = N'COLUMN', @level2name = N'CurrMonthPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Коэф.бонуса за плату пред.мес.(0 или 1000 обычно).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SalarySVis', @level2type = N'COLUMN', @level2name = N'POZPM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плата покупателей в предыдущем месяце', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SalarySVis', @level2type = N'COLUMN', @level2name = N'PrevMonthPay';

