CREATE TABLE [dbo].[MarshHist] (
    [tid]     INT        IDENTITY (1, 1) NOT NULL,
    [mhId]    INT        CONSTRAINT [DF__MarshHist__mhId__7EAD8B99] DEFAULT ((0)) NOT NULL,
    [ND]      DATETIME   CONSTRAINT [DF__MarshHist__ND__0ABE5CC3] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [TM]      CHAR (8)   CONSTRAINT [DF__MarshHist__TM__0BB280FC] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Marsh]   INT        NOT NULL,
    [MarshND] DATETIME   NOT NULL,
    [Dist]    FLOAT (53) NULL,
    [DistPay] MONEY      NULL,
    [DrvPay]  MONEY      NULL,
    [Dots]    INT        NULL,
    [DotsPay] MONEY      NULL,
    [SpedPay] MONEY      NULL,
    [Marja]   MONEY      NULL,
    [Dohod]   MONEY      NULL,
    [op]      INT        NOT NULL,
    [Profit]  MONEY      NULL,
    [WayPay]  MONEY      NULL,
    [VetPay]  MONEY      NULL,
    [mState]  INT        NULL,
    CONSTRAINT [MarshHist_pk] PRIMARY KEY CLUSTERED ([tid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Статус машрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'mState';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата вет. свидетельства', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'VetPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Платная дорога', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'WayPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Прибыль', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'Profit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'доход фирмы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'Dohod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Доход от продаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'Marja';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плата экспедитору', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'SpedPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плата за 1 торг. точку', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'DotsPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во точек в маршруте', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'Dots';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плата водителю', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'DrvPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плата за 1 км', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'DistPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расстояние', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'Dist';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'MarshND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'Marsh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Времы печати маршрутника', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'TM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата печати маршрутника', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'ND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id маршрута в табл Marsh', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshHist', @level2type = N'COLUMN', @level2name = N'mhId';

