CREATE TABLE [dbo].[MarshOplDet] (
    [odId]        INT        IDENTITY (1, 1) NOT NULL,
    [VedNo]       INT        NOT NULL,
    [NdMarsh]     DATETIME   NOT NULL,
    [Marsh]       INT        NOT NULL,
    [OplataSum]   MONEY      CONSTRAINT [DF__MarshOplD__Opata__5D6C935F] DEFAULT ((0)) NULL,
    [OplataOther] MONEY      CONSTRAINT [DF__MarshOplD__Oplat__5E60B798] DEFAULT ((0)) NULL,
    [Dist]        FLOAT (53) CONSTRAINT [DF__MarshOplDe__Dist__7F57970F] DEFAULT ((0)) NULL,
    [DistPay]     FLOAT (53) DEFAULT ((0)) NULL,
    [DrvPay]      FLOAT (53) DEFAULT ((0)) NULL,
    [weight]      FLOAT (53) DEFAULT ((0)) NULL,
    [Dots]        FLOAT (53) DEFAULT ((0)) NULL,
    [DotsPay]     FLOAT (53) DEFAULT ((0)) NULL,
    [SpedPay]     FLOAT (53) DEFAULT ((0)) NULL,
    [PercWorkPay] FLOAT (53) DEFAULT ((0)) NULL,
    [Peni]        FLOAT (53) CONSTRAINT [DF__MarshOplD__DistP__004BBB48] DEFAULT ((0)) NULL,
    [BrDolg]      FLOAT (53) DEFAULT ((0)) NULL,
    [Podotchet]   FLOAT (53) DEFAULT ((0)) NULL,
    [mhid]        INT        NULL,
    PRIMARY KEY CLUSTERED ([odId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MarshOplDet_uq2]
    ON [dbo].[MarshOplDet]([mhid] ASC);


GO
CREATE NONCLUSTERED INDEX [MarshOplDet_uq]
    ON [dbo].[MarshOplDet]([NdMarsh] ASC, [Marsh] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'подотчетные средства', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'Podotchet';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Долг водителя как покупателя(B_id)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'BrDolg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Штрафы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'Peni';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма премиальных выплат за долгосрочное сотрудничество', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'PercWorkPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата экспедитора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'SpedPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 точки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'DotsPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во точек', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'Dots';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Масса', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата 1 кг', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'DrvPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена 1 км', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'DistPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Киллометраж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'Dist';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'другие выплаты (платная дорого+Оплата вет. свидет)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'OplataOther';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выплаты водителю', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'OplataSum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'Marsh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'NdMarsh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ ведомости из табл MarshVedOpl', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet', @level2type = N'COLUMN', @level2name = N'VedNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N' детализация ведомости по оплатам за маршрут', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshOplDet';

