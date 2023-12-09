CREATE TABLE [RetroB].[rb_Main] (
    [RbID]         INT             IDENTITY (1, 1) NOT NULL,
    [ND]           DATETIME        DEFAULT (dateadd(day,datediff(day,(0),getdate()),(0))) NULL,
    [StartDay]     DATETIME        NULL,
    [FinishDay]    DATETIME        NULL,
    [Active]       BIT             DEFAULT ((1)) NULL,
    [PayBySell]    BIT             DEFAULT ((0)) NULL,
    [BonusPerc]    DECIMAL (4, 1)  NULL,
    [Remark]       VARCHAR (50)    NULL,
    [Op]           INT             NULL,
    [Otvet]        VARCHAR (50)    NULL,
    [Qvartal]      BIT             DEFAULT ((0)) NULL,
    [Black]        TINYINT         DEFAULT ((3)) NULL,
    [Treshold12]   BIT             DEFAULT ((0)) NULL,
    [OborBonus]    DECIMAL (10, 2) NULL,
    [flgWoNds]     BIT             DEFAULT ((0)) NULL,
    [SQU]          VARCHAR (2)     NULL,
    [RatePerc]     DECIMAL (5, 2)  DEFAULT ((0)) NULL,
    [BrCount]      SMALLINT        DEFAULT ((1)) NULL,
    [AskAgId]      INT             NULL,
    [DepId]        SMALLINT        NULL,
    [LastConfirm]  DATETIME        NULL,
    [flgRefund]    BIT             DEFAULT ((1)) NULL,
    [RefundPin]    INT             NULL,
    [FondP_ID]     INT             NULL,
    [WayChiefP_ID] INT             NULL,
    [RefundPerc]   DECIMAL (6, 2)  DEFAULT ((100)) NULL,
    [RefundVid]    SMALLINT        NULL,
    [RefundDays]   INT             DEFAULT ((7)) NULL,
    [FirmGroup]    SMALLINT        DEFAULT ((7)) NULL,
    [WeightFlag]   SMALLINT        DEFAULT ((2)) NULL,
    PRIMARY KEY CLUSTERED ([RbID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '0-шт, 1-кг, 2-то и другое', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'WeightFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Фильтр по группе фирм', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'FirmGroup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Число дней до возмещения', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'RefundDays';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Способ возмещения из списка RentabListingOplataVid', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'RefundVid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Доля (процент) возмещения бонуса, 0...100', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'RefundPerc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Руководитель направления, ключ в Person', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'WayChiefP_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фонд списания расходов, ключ в Person', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'FondP_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Поставщик, который возмещает расходы, ключ в Def', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'RefundPin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак возмещения', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'flgRefund';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Количество покупателей', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'BrCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Мин.норма прибыли,%', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'RatePerc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак расчета в ценах без НДС', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'flgWoNds';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Бонус за оборудование', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'OborBonus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-нал 2-товар 3-офиц. 4-банк.карта', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'Black';

