CREATE TABLE [dbo].[ServContract] (
    [SVID]     INT             IDENTITY (1, 1) NOT NULL,
    [ND]       DATETIME        CONSTRAINT [DF__ServContract__ND__391A2450] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [TM]       CHAR (8)        CONSTRAINT [DF__ServContract__TM__3A0E4889] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Doc_Date] DATETIME        NULL,
    [Doc_Nom]  VARCHAR (20)    NULL,
    [Pin]      INT             NULL,
    [SVCat]    INT             CONSTRAINT [DF__ServContr__SVCat__3B026CC2] DEFAULT ((0)) NULL,
    [Remark]   VARCHAR (100)   NULL,
    [Total]    DECIMAL (12, 2) CONSTRAINT [DF__ServContr__Total__3BF690FB] DEFAULT ((0)) NULL,
    [Fact]     DECIMAL (12, 2) CONSTRAINT [DF__ServContra__Fact__3CEAB534] DEFAULT ((0)) NULL,
    [ClosDate] DATETIME        NULL,
    [Comp]     VARCHAR (20)    NULL,
    [OP]       INT             NULL,
    [Srok]     DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([SVID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Срок исполнения договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'Srok';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Хост, где введен договор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'Comp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата закрытия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'ClosDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фактически оплачено', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'Fact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма договора услуг', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'Total';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Категория договора из ServCategory', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'SVCat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'контрагент из DEF', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'Pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер документа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'Doc_Nom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата составления договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'Doc_Date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'TM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата заключения договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'ND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сквозной №', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServContract', @level2type = N'COLUMN', @level2name = N'SVID';

