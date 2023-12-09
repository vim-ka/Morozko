CREATE TABLE [db_FarLogistic].[dlGroupBill] (
    [dlGroupBillID] INT         NOT NULL,
    [MarshID]       INT         NULL,
    [WorkID]        INT         NULL,
    [CasherID]      INT         NULL,
    [ForPay]        MONEY       DEFAULT ((0)) NULL,
    [Paided]        MONEY       DEFAULT ((0)) NULL,
    [GivenDate]     DATETIME    NULL,
    [PaymentDate]   DATETIME    NULL,
    [UnLoaded]      BIT         DEFAULT ((0)) NULL,
    [RealBillID]    VARCHAR (4) CONSTRAINT [DF__dlGroupBi__RealB__5D8403FD] DEFAULT ((0)) NOT NULL,
    [DepID]         INT         DEFAULT ((0)) NOT NULL,
    [ReestrID]      INT         DEFAULT ((0)) NOT NULL,
    CONSTRAINT [UQ__dlGroupB__098D7E84C9F6193F] PRIMARY KEY CLUSTERED ([dlGroupBillID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [dlGroupBill_idx3]
    ON [db_FarLogistic].[dlGroupBill]([WorkID] ASC);


GO
CREATE NONCLUSTERED INDEX [dlGroupBill_idx2]
    ON [db_FarLogistic].[dlGroupBill]([MarshID] ASC);


GO
CREATE NONCLUSTERED INDEX [dlGroupBill_idx]
    ON [db_FarLogistic].[dlGroupBill]([GivenDate] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [dlGroupBill_uq]
    ON [db_FarLogistic].[dlGroupBill]([MarshID] ASC, [WorkID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'флаг выгрузки в 1С', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlGroupBill', @level2type = N'COLUMN', @level2name = N'UnLoaded';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата последнего погашения счета', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlGroupBill', @level2type = N'COLUMN', @level2name = N'PaymentDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата формирования счета', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlGroupBill', @level2type = N'COLUMN', @level2name = N'GivenDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'оплачено', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlGroupBill', @level2type = N'COLUMN', @level2name = N'Paided';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к оплате', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlGroupBill', @level2type = N'COLUMN', @level2name = N'ForPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плательшик', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlGroupBill', @level2type = N'COLUMN', @level2name = N'CasherID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер работы', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlGroupBill', @level2type = N'COLUMN', @level2name = N'WorkID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер маршрута', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlGroupBill', @level2type = N'COLUMN', @level2name = N'MarshID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер счета', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlGroupBill', @level2type = N'COLUMN', @level2name = N'dlGroupBillID';

