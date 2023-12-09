CREATE TABLE [dbo].[DefLog] (
    [tip]             TINYINT         NULL,
    [gpName]          VARCHAR (100)   NULL,
    [gpIndex]         VARCHAR (6)     NULL,
    [gpAddr]          VARCHAR (200)   NULL,
    [gpRs]            VARCHAR (20)    NULL,
    [gpCs]            VARCHAR (20)    NULL,
    [gpBank]          VARCHAR (128)   NULL,
    [gpBik]           VARCHAR (9)     NULL,
    [gpInn]           VARCHAR (12)    NULL,
    [gpKpp]           VARCHAR (9)     NULL,
    [brName]          VARCHAR (100)   NULL,
    [brIndex]         CHAR (6)        NULL,
    [brAddr]          VARCHAR (200)   NULL,
    [brRs]            VARCHAR (20)    NULL,
    [brCs]            VARCHAR (20)    NULL,
    [brBank]          VARCHAR (128)   NULL,
    [brBik]           VARCHAR (9)     NULL,
    [brInn]           VARCHAR (12)    NULL,
    [brKpp]           VARCHAR (9)     NULL,
    [brAg_ID]         INT             NULL,
    [Fam]             VARCHAR (30)    NULL,
    [gpPhone]         VARCHAR (50)    NULL,
    [brPhone]         VARCHAR (50)    NULL,
    [Remark]          VARCHAR (40)    NULL,
    [RemarkDate]      DATETIME        NULL,
    [Limit]           MONEY           NULL,
    [PosX]            NUMERIC (9, 6)  NULL,
    [PosY]            NUMERIC (9, 6)  NULL,
    [FullDocs]        BIT             NULL,
    [Srok]            NUMERIC (3)     NULL,
    [Actual]          BIT             NULL,
    [Disab]           BIT             NOT NULL,
    [Extra]           NUMERIC (6, 2)  NULL,
    [LicNo]           VARCHAR (25)    NULL,
    [LicWho]          VARCHAR (40)    NULL,
    [LicSrok]         DATETIME        NULL,
    [LicDate]         DATETIME        NULL,
    [Raz]             NUMERIC (1)     NULL,
    [BeginDate]       DATETIME        NULL,
    [Contact]         VARCHAR (50)    NULL,
    [Oborot]          MONEY           NULL,
    [Master]          NUMERIC (5)     NULL,
    [Our_ID]          NUMERIC (2)     NULL,
    [Buh_ID]          NUMERIC (3)     NULL,
    [Reg_ID]          VARCHAR (5)     NOT NULL,
    [Rn_ID]           NUMERIC (4)     NULL,
    [Obl_ID]          NUMERIC (3)     NULL,
    [Sver]            BIT             NULL,
    [NeedSver]        BIT             NULL,
    [Prior]           BIT             NULL,
    [LastSver]        DATETIME        NULL,
    [PeriodSver]      NUMERIC (4)     NULL,
    [ShortFam]        VARCHAR (40)    NULL,
    [Torg12]          BIT             NULL,
    [TovChk]          BIT             NULL,
    [NetType]         NUMERIC (2)     NULL,
    [GrOt]            NUMERIC (2)     NULL,
    [Fmt]             NUMERIC (2)     NULL,
    [PrevAgID]        NUMERIC (4)     NULL,
    [OKPO]            VARCHAR (10)    NULL,
    [OKPO2]           VARCHAR (10)    NULL,
    [NDSFlg]          BIT             NULL,
    [Ag_GRP]          NUMERIC (1)     NULL,
    [Debit]           BIT             NULL,
    [OGRN]            VARCHAR (15)    NULL,
    [tmDin]           VARCHAR (15)    NULL,
    [tmWork]          VARCHAR (15)    NULL,
    [OGRNDate]        DATETIME        NULL,
    [SlAll]           BIT             NULL,
    [DisMinEXTRA]     BIT             NULL,
    [Tov]             NUMERIC (2)     NULL,
    [BNFlg]           BIT             NULL,
    [Worker]          BIT             NULL,
    [TmPost]          VARCHAR (8)     NULL,
    [SkipIce]         DATETIME        NULL,
    [SkipPf]          DATETIME        NULL,
    [Zarp]            DECIMAL (8, 2)  NULL,
    [LastFrizSver]    DATETIME        NULL,
    [Bonus]           BIT             NULL,
    [IceNorm]         MONEY           NULL,
    [PfNorm]          MONEY           NULL,
    [Op]              INT             NULL,
    [dstAddr]         VARCHAR (200)   NULL,
    [wostamp]         BIT             NULL,
    [SumFriz]         BIT             NULL,
    [SverTara]        DATETIME        NULL,
    [OborotIce]       MONEY           NULL,
    [Part]            DECIMAL (5, 2)  NULL,
    [Bank_ID]         SMALLINT        NULL,
    [LimitOver]       MONEY           NULL,
    [Priority]        TINYINT         NULL,
    [NaklCopy]        TINYINT         NULL,
    [brFullName]      VARCHAR (200)   NULL,
    [C1Code]          VARCHAR (11)    NULL,
    [gln]             VARCHAR (13)    NULL,
    [LicScan]         DATETIME        NULL,
    [tradeArea]       NUMERIC (10, 2) NULL,
    [brag_id2]        INT             NULL,
    [Vmaster]         INT             NULL,
    [NDPret]          DATETIME        NULL,
    [NDPretBack]      DATETIME        NULL,
    [Email]           VARCHAR (100)   NULL,
    [Ncod]            INT             NULL,
    [NDCoord]         DATETIME        NULL,
    [dfID]            SMALLINT        NULL,
    [upin]            INT             NULL,
    [MainMaster]      INT             NULL,
    [OKDP]            VARCHAR (20)    NULL,
    [gpRegCode]       VARCHAR (3)     NULL,
    [gpAddr_city]     VARCHAR (30)    NULL,
    [gpAddr_NasPunct] VARCHAR (30)    NULL,
    [gpAddr_Street]   VARCHAR (30)    NULL,
    [gpAddr_House]    VARCHAR (5)     NULL,
    [gpAddr_Corp]     VARCHAR (5)     NULL,
    [gpAddr_Room]     VARCHAR (5)     NULL,
    [pin]             INT             NOT NULL,
    [type]            SMALLINT        NULL,
    [user_name]       NVARCHAR (256)  DEFAULT (suser_sname()) NULL,
    [datetime]        DATETIME        DEFAULT (getdate()) NULL,
    [host_name]       NCHAR (30)      DEFAULT (host_name()) NULL,
    [app_name]        NVARCHAR (128)  DEFAULT (app_name()) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_deflogpin]
    ON [dbo].[DefLog]([pin] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя приложения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefLog', @level2type = N'COLUMN', @level2name = N'app_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя компа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefLog', @level2type = N'COLUMN', @level2name = N'host_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefLog', @level2type = N'COLUMN', @level2name = N'datetime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя пользователя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefLog', @level2type = N'COLUMN', @level2name = N'user_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип изменения 0 - insert, 1 - delete, 2 - update', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefLog', @level2type = N'COLUMN', @level2name = N'type';

