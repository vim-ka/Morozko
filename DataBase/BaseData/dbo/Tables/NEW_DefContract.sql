CREATE TABLE [dbo].[NEW_DefContract] (
    [DCK]                 INT             IDENTITY (1, 1) NOT NULL,
    [ND]                  DATETIME        DEFAULT (getdate()) NULL,
    [OP]                  INT             NULL,
    [Actual]              BIT             DEFAULT ((1)) NULL,
    [Our_id]              INT             CONSTRAINT [DF__DefContra__Our_i__2DAAD3A9_copy] DEFAULT ((0)) NOT NULL,
    [ContrTip]            INT             NULL,
    [pin]                 INT             NULL,
    [ContrName]           VARCHAR (80)    NULL,
    [ContrMain]           BIT             DEFAULT ((0)) NULL,
    [ContrNum]            VARCHAR (50)    NULL,
    [ContrDate]           DATETIME        NULL,
    [ContrEvalDate]       DATETIME        NULL,
    [Srok]                INT             DEFAULT ((0)) NOT NULL,
    [BnFlag]              BIT             DEFAULT ((0)) NULL,
    [NDS]                 BIT             DEFAULT ((0)) NULL,
    [minOrder]            NUMERIC (10, 3) NULL,
    [maxDaysOrder]        INT             NULL,
    [LastSver]            DATETIME        NULL,
    [Remark]              VARCHAR (200)   NULL,
    [gpOur_ID]            TINYINT         NULL,
    [Bank_ID]             INT             NULL,
    [p_id]                INT             DEFAULT ((0)) NULL,
    [limit]               MONEY           CONSTRAINT [DF__DefContra__limit__5701EEF7_copy] DEFAULT ((100000)) NOT NULL,
    [Extra]               FLOAT (53)      NULL,
    [wostamp]             BIT             NULL,
    [DCKOld]              INT             NULL,
    [PrevP_id]            INT             DEFAULT ((0)) NULL,
    [AccountID]           INT             NULL,
    [ag_id]               INT             DEFAULT ((0)) NOT NULL,
    [PrevAg_ID]           INT             NULL,
    [NeedFrizSver]        BIT             CONSTRAINT [DF__DefContra__NeedF__354BF571_copy] DEFAULT ((0)) NOT NULL,
    [LastFrizSver]        DATETIME        NULL,
    [Degust]              INT             DEFAULT ((0)) NULL,
    [dcnID]               INT             NULL,
    [DckMaster]           INT             DEFAULT ((0)) NULL,
    [NeedCK]              BIT             DEFAULT ((0)) NULL,
    [Factoring]           BIT             DEFAULT ((0)) NULL,
    [PrintStandartPhrase] BIT             DEFAULT ((0)) NULL,
    [Ncod]                INT             DEFAULT ((0)) NULL,
    [ExpressSver]         DATETIME        NULL,
    [Disab]               BIT             DEFAULT ((0)) NULL,
    [Debit]               BIT             DEFAULT ((0)) NULL,
    [gpBank_ID]           INT             DEFAULT ((8)) NULL,
    [FMonDisab]           BIT             DEFAULT ((0)) NULL,
    [TaxMID]              INT             DEFAULT ((0)) NULL,
    [PricePrecision]      SMALLINT        DEFAULT ((2)) NULL,
    [GPAccountID]         INT             DEFAULT ((1)) NOT NULL,
    [Old_DCK]             INT             NULL,
    CONSTRAINT [DefContract_fk_copy] FOREIGN KEY ([ContrTip]) REFERENCES [dbo].[DefContractTip] ([ContrTip]) ON UPDATE CASCADE,
    CONSTRAINT [DefContract_fk2_copy] FOREIGN KEY ([dcnID]) REFERENCES [dbo].[DefContractNDSType] ([dcnID]) ON UPDATE CASCADE,
    UNIQUE NONCLUSTERED ([DCK] ASC)
);


GO
CREATE NONCLUSTERED INDEX [DefContract_Pin_idx]
    ON [dbo].[NEW_DefContract]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [DefContract_idx3]
    ON [dbo].[NEW_DefContract]([p_id] ASC);


GO
CREATE NONCLUSTERED INDEX [DefContract_idx2]
    ON [dbo].[NEW_DefContract]([ag_id] ASC);


GO
CREATE NONCLUSTERED INDEX [DefContract_idx]
    ON [dbo].[NEW_DefContract]([ContrTip] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Точность представления цены', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'PricePrecision';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Система налогооблажения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'TaxMID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Флаг запрета внеочередных посещений. Обновляется из FMonitor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'FMonDisab';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Blocked', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Debit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Блокировка договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Disab';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Экспресс-сверка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'ExpressSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для перехода с Vendors на Def', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Ncod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Печать в ТОРГ-12 Вместо № договора стандартной фразы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'PrintStandartPhrase';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор, по которому оплату за поставки совершает банк', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Factoring';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Требуется кассовый чек', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'NeedCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код мастера-договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'DckMaster';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'налог поставщика (10,18 или смешанный)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'dcnID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор - дегустация, дебиторка переносится в п/о контрагенту ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Degust';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата последней сверки оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'LastFrizSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Необходимость сверки оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'NeedFrizSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Предыдущий агент', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'PrevAg_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код агента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'ag_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетный счет от нас', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'AccountID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'PrevP_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'DCKOld';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Не требуется печать', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'wostamp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наценка/Скидка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Extra';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Лимит продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'limit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код агента К удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'p_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетный счет от нас', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Bank_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Организация грузоотправитель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'gpOur_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата сверки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'LastSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Максимальный заказ в днях', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'maxDaysOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Минимальный заказ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'minOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плательщик НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'NDS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Безнальный расчет', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'BnFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Срок консигнации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Srok';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата окончания договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'ContrEvalDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор от', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'ContrDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'ContrNum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Основной договор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'ContrMain';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'ContrName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код контрагента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'ContrTip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Организация', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Our_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Действующий', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'Actual';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оператор, добавивший договор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата внесения договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_DefContract', @level2type = N'COLUMN', @level2name = N'ND';

