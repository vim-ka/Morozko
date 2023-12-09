CREATE TABLE [dbo].[DefContractRez] (
    [DCK]           INT             NOT NULL,
    [ND]            DATETIME        CONSTRAINT [DF__DefContract__ND__48D1692C1] DEFAULT (getdate()) NULL,
    [OP]            INT             NULL,
    [Actual]        BIT             CONSTRAINT [DF__DefContra__Actua__2F1197291] DEFAULT ((1)) NULL,
    [Our_id]        TINYINT         NULL,
    [ContrTip]      INT             NULL,
    [pin]           INT             NULL,
    [ContrName]     VARCHAR (80)    NULL,
    [ContrMain]     BIT             CONSTRAINT [DF__DefContra__Contr__34CA707F1] DEFAULT ((0)) NULL,
    [ContrNum]      VARCHAR (50)    NULL,
    [ContrDate]     DATETIME        NULL,
    [ContrEvalDate] DATETIME        NULL,
    [Srok]          INT             NULL,
    [BnFlag]        BIT             NULL,
    [NDS]           BIT             NULL,
    [minOrder]      NUMERIC (10, 3) NULL,
    [maxDaysOrder]  INT             NULL,
    [LastSver]      DATETIME        NULL,
    [Remark]        VARCHAR (200)   NULL,
    [gpOur_ID]      TINYINT         NULL,
    [Bank_ID]       INT             NULL,
    [p_id]          INT             NULL,
    [limit]         MONEY           NULL,
    [Extra]         FLOAT (53)      NULL,
    [wostamp]       BIT             NULL,
    [DCKOld]        INT             NULL,
    UNIQUE NONCLUSTERED ([DCK] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Не требуется печать', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'wostamp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наценка/Скидка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'Extra';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Лимит продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'limit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код агента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'p_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетный счет от нас', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'Bank_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Организация грузоотправитель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'gpOur_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Срок консигнации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'Srok';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата окончания договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'ContrEvalDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор от', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'ContrDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'ContrNum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Основной договор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'ContrMain';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'ContrName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код контрагента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'ContrTip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Организация', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'Our_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Действующий', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'Actual';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оператор, добавивший договор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата внесения договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefContractRez', @level2type = N'COLUMN', @level2name = N'ND';

