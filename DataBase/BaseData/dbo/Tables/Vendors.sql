CREATE TABLE [dbo].[Vendors] (
    [ncod]        INT             NOT NULL,
    [fam]         VARCHAR (50)    NULL,
    [rang]        CHAR (1)        NULL,
    [addr]        VARCHAR (100)   NULL,
    [actual]      BIT             DEFAULT ((1)) NULL,
    [inn]         VARCHAR (12)    NULL,
    [licno]       VARCHAR (25)    NULL,
    [licwho]      CHAR (40)       NULL,
    [licsrok]     DATETIME        NULL,
    [nac]         NUMERIC (6, 2)  NULL,
    [isweight]    BIT             DEFAULT ((0)) NULL,
    [hidden]      BIT             DEFAULT ((0)) NULL,
    [srok]        NUMERIC (4)     NULL,
    [phone]       CHAR (40)       NULL,
    [contact]     CHAR (50)       NULL,
    [bank]        VARCHAR (50)    NULL,
    [bik]         VARCHAR (9)     NULL,
    [r_schet]     VARCHAR (50)    NULL,
    [c_schet]     VARCHAR (50)    NULL,
    [kpp]         VARCHAR (9)     NULL,
    [our_id]      NUMERIC (2)     CONSTRAINT [DF__Vendors__our_id__2B0B30C4] DEFAULT ((7)) NULL,
    [addr_f]      VARCHAR (100)   NULL,
    [dogovor]     VARCHAR (50)    NULL,
    [bnflag]      BIT             NULL,
    [refncod]     NUMERIC (4)     CONSTRAINT [DF__Vendors__refncod__727BF387] DEFAULT (0) NULL,
    [tnorm]       NUMERIC (2)     NULL,
    [agent]       NUMERIC (2)     NULL,
    [w]           BIT             NULL,
    [nds]         BIT             NULL,
    [minOrder]    NUMERIC (10, 3) NULL,
    [prdolg]      MONEY           CONSTRAINT [DF__Vendors__prdolg__737017C0] DEFAULT (0) NULL,
    [buh_uin]     INT             CONSTRAINT [DF__Vendors__buh_uin__37461F20] DEFAULT ((38)) NULL,
    [maxDaysOrd]  INT             DEFAULT ((20)) NULL,
    [realiz]      MONEY           NULL,
    [begDate]     DATETIME        DEFAULT (getdate()) NULL,
    [LastSver]    DATETIME        NULL,
    [addrPost]    VARCHAR (100)   NULL,
    [OKPO]        VARCHAR (10)    NULL,
    [Email]       VARCHAR (100)   NULL,
    [PercExpDate] INT             CONSTRAINT [DF__Vendors__PercExp__6D0F94F9] DEFAULT ((20)) NULL,
    [DiscardProc] DECIMAL (5, 2)  NULL,
    [cat_uin]     INT             NULL,
    CONSTRAINT [Vendors_pk] PRIMARY KEY CLUSTERED ([ncod] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Категорийный менеджер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vendors', @level2type = N'COLUMN', @level2name = N'cat_uin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Процент от срока годности возможный при поставке от данного поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vendors', @level2type = N'COLUMN', @level2name = N'PercExpDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Почтовый адрес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vendors', @level2type = N'COLUMN', @level2name = N'addrPost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата последней сверки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vendors', @level2type = N'COLUMN', @level2name = N'LastSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата заведения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vendors', @level2type = N'COLUMN', @level2name = N'begDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'связь с usrpwd.uin - код менеджера для поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vendors', @level2type = N'COLUMN', @level2name = N'buh_uin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адрес фактический', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vendors', @level2type = N'COLUMN', @level2name = N'addr_f';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адрес юридический', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vendors', @level2type = N'COLUMN', @level2name = N'addr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vendors', @level2type = N'COLUMN', @level2name = N'fam';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД Поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Vendors', @level2type = N'COLUMN', @level2name = N'ncod';

