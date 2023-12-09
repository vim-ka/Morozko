CREATE TABLE [dbo].[PayMoneyHist] (
    [pmhID]    INT          IDENTITY (1, 1) NOT NULL,
    [ND]       DATETIME     DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]       CHAR (8)     CONSTRAINT [DF__PayMoneyHist__TM__61A73897] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Marsh]    INT          NULL,
    [MarshND]  DATETIME     NULL,
    [mPayFact] MONEY        NULL,
    [mPay]     MONEY        NULL,
    [Remark]   VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([pmhID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'оплата по тарифу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PayMoneyHist', @level2type = N'COLUMN', @level2name = N'mPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фактическая выплата водителю', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PayMoneyHist', @level2type = N'COLUMN', @level2name = N'mPayFact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PayMoneyHist', @level2type = N'COLUMN', @level2name = N'MarshND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PayMoneyHist', @level2type = N'COLUMN', @level2name = N'Marsh';

