CREATE TABLE [dbo].[Banks_for_delete] (
    [Bank_ID]     INT           NOT NULL,
    [BnK]         INT           CONSTRAINT [DF__Banks__BnK__0DC5B1F7] DEFAULT ((0)) NOT NULL,
    [BName]       VARCHAR (80)  NULL,
    [p_id]        INT           NULL,
    [Our_ID]      INT           NULL,
    [Address]     VARCHAR (50)  NULL,
    [BIK]         VARCHAR (15)  NULL,
    [CShet]       VARCHAR (254) NULL,
    [RShet]       VARCHAR (254) NULL,
    [INN]         VARCHAR (10)  NULL,
    [OKPO]        VARCHAR (15)  NULL,
    [KPP]         VARCHAR (15)  NULL,
    [OGRN]        VARCHAR (20)  NULL,
    [RschetMoney] MONEY         CONSTRAINT [DF__Banks__RscetMone__5689C04F] DEFAULT ((0)) NOT NULL,
    [RshetNo]     VARCHAR (20)  NULL,
    [DefaultFlag] BIT           NULL,
    [Actual]      BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Bank_ID] ASC),
    CONSTRAINT [Banks_fk] FOREIGN KEY ([BnK]) REFERENCES [dbo].[BankList] ([BnK]) ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Р/С активен', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banks_for_delete', @level2type = N'COLUMN', @level2name = N'Actual';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Р/с по умолчанию', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banks_for_delete', @level2type = N'COLUMN', @level2name = N'DefaultFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетный счет', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banks_for_delete', @level2type = N'COLUMN', @level2name = N'RShet';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Корреспондентский счет', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banks_for_delete', @level2type = N'COLUMN', @level2name = N'CShet';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код банка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banks_for_delete', @level2type = N'COLUMN', @level2name = N'BnK';

