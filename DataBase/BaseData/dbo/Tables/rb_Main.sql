CREATE TABLE [dbo].[rb_Main] (
    [RbID]       INT             IDENTITY (1, 1) NOT NULL,
    [ND]         DATETIME        CONSTRAINT [DF__rb_Main__ND__1FC531F8] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [StartDay]   DATETIME        NULL,
    [FinishDay]  DATETIME        NULL,
    [Active]     BIT             CONSTRAINT [DF__rb_Main__Active__20B95631] DEFAULT ((1)) NULL,
    [PayBySell]  BIT             CONSTRAINT [DF__rb_Main__PayBySe__21AD7A6A] DEFAULT ((0)) NULL,
    [BonusPerc]  DECIMAL (4, 1)  NULL,
    [Remark]     VARCHAR (50)    NULL,
    [Op]         INT             NULL,
    [Otvet]      VARCHAR (50)    NULL,
    [Qvartal]    BIT             CONSTRAINT [DF__rb_Main__Qvartal__6B274C87] DEFAULT ((0)) NULL,
    [Black]      TINYINT         CONSTRAINT [DF__rb_Main__Black__6C1B70C0] DEFAULT ((3)) NULL,
    [Treshold12] BIT             CONSTRAINT [DF__rb_Main__Treshol__7F2E4534] DEFAULT ((0)) NULL,
    [OborBonus]  DECIMAL (10, 2) NULL,
    [flgWoNds]   BIT             CONSTRAINT [DF__rb_Main__flgWoNd__56F636A8] DEFAULT ((0)) NULL,
    [SQU]        VARCHAR (2)     NULL,
    [AskAgId]    INT             NULL,
    [DepId]      SMALLINT        NULL,
    [RatePerc]   DECIMAL (5, 2)  NULL,
    [brCount]    SMALLINT        DEFAULT ((1)) NULL,
    [OurID]      INT             DEFAULT ((7)) NULL,
    CONSTRAINT [PK__rb_Main__DF460600C262588A] PRIMARY KEY CLUSTERED ([RbID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак расчета в ценах без НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'flgWoNds';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Бонус за оборудование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'OborBonus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-нал 2-товар 3-офиц. 4-банк.карта', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'rb_Main', @level2type = N'COLUMN', @level2name = N'Black';

