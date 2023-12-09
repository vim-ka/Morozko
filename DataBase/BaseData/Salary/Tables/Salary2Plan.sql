CREATE TABLE [Salary].[Salary2Plan] (
    [spID]         INT             IDENTITY (1, 1) NOT NULL,
    [DepID]        INT             NULL,
    [yyyymm]       INT             NOT NULL,
    [NGrp]         SMALLINT        NULL,
    [PlanRub]      DECIMAL (12, 2) NULL,
    [PlanKG]       DECIMAL (12, 2) NULL,
    [SellM12rub]   DECIMAL (12, 2) NULL,
    [SellM12kg]    DECIMAL (12, 2) NULL,
    [SellM1rub]    DECIMAL (12, 2) NULL,
    [sellm1kg]     DECIMAL (12, 2) NULL,
    [CatPriceRub]  DECIMAL (8, 2)  NULL,
    [CatPricePerc] DECIMAL (8, 4)  NULL,
    [FactSellRub]  DECIMAL (12, 2) NULL,
    [FactSellKg]   DECIMAL (12, 2) NULL,
    PRIMARY KEY CLUSTERED ([spID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'То же в кг', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'FactSellKg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фактические продажи в заданном месяце, руб', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'FactSellRub';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость категори, %', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'CatPricePerc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость категории, руб.', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'CatPriceRub';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'То же в кг', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'sellm1kg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Продажи за предыдущий месяц, т.е. январь 2016, руб', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'SellM1rub';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'То же в кг', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'SellM12kg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Продажи за аналогичный месяц пред.года, т.е. февраль 2015, руб', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'SellM12rub';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'План продаж в кг, аналогично', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'PlanKG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'План продаж в рублях на заданный месяц, например, февраль 2016', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'PlanRub';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Год и месяц в формате YYYYMM', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Plan', @level2type = N'COLUMN', @level2name = N'yyyymm';

