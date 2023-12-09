CREATE TABLE [dbo].[BankSheet] (
    [AccountID]   INT           IDENTITY (1, 1) NOT NULL,
    [BnK]         INT           CONSTRAINT [DF__BankSheet__BnK__279B5DEA] DEFAULT ((0)) NOT NULL,
    [DefaultFlag] BIT           NULL,
    [p_id]        INT           NULL,
    [Our_ID]      TINYINT       NULL,
    [RShet]       VARCHAR (254) NULL,
    [RshetNo]     VARCHAR (20)  NULL,
    [RschetMoney] MONEY         CONSTRAINT [DF__BankSheet__Rsche__288F8223] DEFAULT ((0)) NOT NULL,
    [Actual]      BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([AccountID] ASC),
    CONSTRAINT [BankSheet_fk] FOREIGN KEY ([BnK]) REFERENCES [dbo].[BankList] ([BnK]) ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетный счет активен', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BankSheet', @level2type = N'COLUMN', @level2name = N'Actual';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Остаток средств на счете на утро', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BankSheet', @level2type = N'COLUMN', @level2name = N'RschetMoney';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Р/счет (только номер)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BankSheet', @level2type = N'COLUMN', @level2name = N'RshetNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетный счет', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BankSheet', @level2type = N'COLUMN', @level2name = N'RShet';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код фирмы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BankSheet', @level2type = N'COLUMN', @level2name = N'Our_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Р/с по умолчанию', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BankSheet', @level2type = N'COLUMN', @level2name = N'DefaultFlag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код банка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BankSheet', @level2type = N'COLUMN', @level2name = N'BnK';

