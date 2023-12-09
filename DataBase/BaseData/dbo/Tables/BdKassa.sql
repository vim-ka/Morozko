CREATE TABLE [dbo].[BdKassa] (
    [BkID]     INT          IDENTITY (1, 1) NOT NULL,
    [nd]       DATETIME     CONSTRAINT [DF__BdKassa__nd__060EB63F] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [tm]       CHAR (8)     CONSTRAINT [DF__BdKassa__tm__0702DA78] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Oper]     INT          NULL,
    [Plata]    MONEY        CONSTRAINT [DF__BdKassa__Plata__7B4643B2] DEFAULT ((0)) NOT NULL,
    [Remark]   VARCHAR (60) NULL,
    [RashFlag] INT          NULL,
    [LostFlag] INT          NULL,
    [LastFlag] TINYINT      NULL,
    [Op]       INT          NULL,
    [Our_ID]   INT          NULL,
    [DepID]    INT          CONSTRAINT [DF__BdKassa__DepID__6740165C] DEFAULT ((0)) NULL,
    [PlanND]   DATETIME     NULL,
    [Period]   INT          CONSTRAINT [DF__BdKassa__Period__27AFA12C] DEFAULT ((0)) NULL,
    [pin]      INT          NULL,
    [Tip]      INT          NULL,
    [BdND]     DATETIME     NULL,
    CONSTRAINT [BdKassa_pk] PRIMARY KEY CLUSTERED ([BkID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Месяц Год бюджета', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BdKassa', @level2type = N'COLUMN', @level2name = N'BdND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип контрагента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BdKassa', @level2type = N'COLUMN', @level2name = N'Tip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код контрагента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BdKassa', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Период (в днях) для периодических операций, 0 - операция разовая.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BdKassa', @level2type = N'COLUMN', @level2name = N'Period';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Планируемая дата', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BdKassa', @level2type = N'COLUMN', @level2name = N'PlanND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код отдела', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BdKassa', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BdKassa', @level2type = N'COLUMN', @level2name = N'Plata';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время операции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BdKassa', @level2type = N'COLUMN', @level2name = N'tm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата операции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BdKassa', @level2type = N'COLUMN', @level2name = N'nd';

