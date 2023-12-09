CREATE TABLE [dbo].[NEW_def] (
    [pin]             INT             IDENTITY (1, 1) NOT NULL,
    [tip]             TINYINT         CONSTRAINT [DF__Def__tip__4B7734FF_copy] DEFAULT ((1)) NULL,
    [gpName]          VARCHAR (255)   NULL,
    [gpIndex]         VARCHAR (6)     NULL,
    [gpAddr]          VARCHAR (255)   CONSTRAINT [DF__Def__gpAddr__0B9D7263_copy] DEFAULT ('') NULL,
    [gpRs]            VARCHAR (20)    NULL,
    [gpCs]            VARCHAR (20)    NULL,
    [gpBank]          VARCHAR (60)    NULL,
    [gpBik]           VARCHAR (9)     NULL,
    [gpInn]           VARCHAR (12)    NULL,
    [gpKpp]           VARCHAR (9)     NULL,
    [brName]          VARCHAR (255)   NULL,
    [brIndex]         CHAR (6)        NULL,
    [brAddr]          VARCHAR (255)   NULL,
    [brRs]            VARCHAR (20)    NULL,
    [brCs]            VARCHAR (20)    NULL,
    [brBank]          VARCHAR (128)   NULL,
    [brBik]           VARCHAR (9)     NULL,
    [brInn]           VARCHAR (12)    NULL,
    [brKpp]           VARCHAR (9)     NULL,
    [brAg_ID]         INT             CONSTRAINT [DF__Def__brAg_ID__58D1301D_copy] DEFAULT ((0)) NULL,
    [Fam]             VARCHAR (30)    NULL,
    [gpPhone]         VARCHAR (50)    NULL,
    [brPhone]         VARCHAR (50)    NULL,
    [Remark]          VARCHAR (40)    NULL,
    [RemarkDate]      DATETIME        NULL,
    [Limit]           MONEY           CONSTRAINT [DF__Def__Limit__2685A772_copy] DEFAULT ((0)) NULL,
    [PosX]            NUMERIC (9, 6)  CONSTRAINT [DF__Def__PosX__4A19C7C9_copy] DEFAULT ((0)) NULL,
    [PosY]            NUMERIC (9, 6)  CONSTRAINT [DF__Def__PosY__4B0DEC02_copy] DEFAULT ((0)) NULL,
    [FullDocs]        BIT             CONSTRAINT [DF__Def__FullDocs__226AFDCB_copy] DEFAULT ((0)) NULL,
    [Srok]            NUMERIC (3)     CONSTRAINT [DF__Def__Srok__1A5FC7AF_copy] DEFAULT ((0)) NULL,
    [Actual]          BIT             CONSTRAINT [DF__Def__Actual__01C9240F_copy] DEFAULT ((1)) NULL,
    [Disab]           BIT             CONSTRAINT [DF__Def__Disab__2176D992_copy] DEFAULT ((0)) NOT NULL,
    [Extra]           NUMERIC (6, 2)  CONSTRAINT [DF__Def__Extra__14A6EE59_copy] DEFAULT ((0)) NULL,
    [LicNo]           VARCHAR (25)    NULL,
    [LicWho]          VARCHAR (40)    NULL,
    [LicSrok]         DATETIME        NULL,
    [LicDate]         DATETIME        NULL,
    [Raz]             NUMERIC (1)     CONSTRAINT [DF__Def__Raz__0722D609_copy] DEFAULT ((0)) NULL,
    [BeginDate]       DATETIME        CONSTRAINT [DF__Def__BeginDate__2E7278AB_copy] DEFAULT (getdate()) NULL,
    [Contact]         VARCHAR (50)    NULL,
    [Oborot]          MONEY           CONSTRAINT [DF__Def__Oborot__69927322_copy] DEFAULT ((0)) NULL,
    [Master]          NUMERIC (5)     CONSTRAINT [DF__Def__Master__1BBE003C_copy] DEFAULT ((0)) NULL,
    [Our_ID]          NUMERIC (2)     CONSTRAINT [DF__Def__Our_ID__17835B04_copy] DEFAULT ((6)) NULL,
    [Buh_ID]          NUMERIC (3)     CONSTRAINT [DF__Def__Buh_ID__0CDBAF5F_copy] DEFAULT ((0)) NOT NULL,
    [Reg_ID]          VARCHAR (5)     CONSTRAINT [DF__Def__Reg_ID__159B1292_copy] DEFAULT ('А') NOT NULL,
    [Rn_ID]           NUMERIC (4)     CONSTRAINT [DF__Def__Rn_ID__01892CED_copy] DEFAULT ((0)) NOT NULL,
    [Obl_ID]          NUMERIC (3)     CONSTRAINT [DF__Def__Obl_ID__027D5126_copy] DEFAULT ((0)) NOT NULL,
    [Sver]            BIT             CONSTRAINT [DF__Def__Sver__1DA648AE_copy] DEFAULT ((0)) NULL,
    [NeedSver]        BIT             CONSTRAINT [DF__Def__NeedSver__1CB22475_copy] DEFAULT ((0)) NULL,
    [Prior]           BIT             CONSTRAINT [DF__Def__Prior__6F7569AA_copy] DEFAULT ((0)) NULL,
    [LastSver]        DATETIME        NULL,
    [PeriodSver]      NUMERIC (4)     CONSTRAINT [DF__Def__PeriodSver__0DCFD398_copy] DEFAULT ((0)) NULL,
    [ShortFam]        VARCHAR (40)    NULL,
    [Torg12]          BIT             CONSTRAINT [DF__Def__Torg12__1E9A6CE7_copy] DEFAULT ((0)) NULL,
    [TovChk]          BIT             CONSTRAINT [DF__Def__TovChk__1F8E9120_copy] DEFAULT ((0)) NULL,
    [NetType]         NUMERIC (2)     CONSTRAINT [DF__Def__NetType__090B1E7B_copy] DEFAULT ((0)) NULL,
    [GrOt]            NUMERIC (2)     CONSTRAINT [DF__Def__GrOt__09FF42B4_copy] DEFAULT ((0)) NULL,
    [Fmt]             NUMERIC (2)     CONSTRAINT [DF__Def__Fmt__0AF366ED_copy] DEFAULT ((0)) NULL,
    [PrevAgID]        NUMERIC (4)     CONSTRAINT [DF__Def__PrevAgID__18777F3D_copy] DEFAULT ((0)) NULL,
    [OKPO]            VARCHAR (10)    NULL,
    [OKPO2]           VARCHAR (10)    NULL,
    [NDSFlg]          BIT             CONSTRAINT [DF__Def__NDSFlg__2082B559_copy] DEFAULT ((0)) NULL,
    [Ag_GRP]          NUMERIC (1)     CONSTRAINT [DF__Def__Ag_GRP__0816FA42_copy] DEFAULT ((0)) NULL,
    [Debit]           BIT             CONSTRAINT [DF__Def__Debit__6C8E1007_copy] DEFAULT ((0)) NULL,
    [OGRN]            VARCHAR (15)    NULL,
    [tmDin]           VARCHAR (15)    NULL,
    [tmWork]          VARCHAR (15)    NULL,
    [OGRNDate]        DATETIME        NULL,
    [SlAll]           BIT             CONSTRAINT [DF__Def__SlAll__6B64E1A4_copy] DEFAULT ((0)) NULL,
    [DisMinEXTRA]     BIT             CONSTRAINT [DF__Def__DisMinEXTRA__7C8F6DA6_copy] DEFAULT ((0)) NULL,
    [Tov]             NUMERIC (2)     CONSTRAINT [DF__Def__Tov__0BE78B26_copy] DEFAULT ((0)) NULL,
    [BNFlg]           BIT             CONSTRAINT [DF__Def__BNFlg__1AC9DC03_copy] DEFAULT ((0)) NULL,
    [Worker]          BIT             CONSTRAINT [DF__Def__Worker__52B92F6B_copy] DEFAULT ((0)) NULL,
    [TmPost]          VARCHAR (8)     NULL,
    [SkipIce]         DATETIME        NULL,
    [SkipPf]          DATETIME        NULL,
    [Zarp]            DECIMAL (8, 2)  CONSTRAINT [DF__Def__Zarp__0599B4F3_copy] DEFAULT ((0)) NULL,
    [LastFrizSver]    DATETIME        NULL,
    [Bonus]           BIT             CONSTRAINT [DF__Def__Bonus__2512604C_copy] DEFAULT ((0)) NULL,
    [IceNorm]         MONEY           CONSTRAINT [DF__Def__IceNorm__6A86975B_copy] DEFAULT ((0)) NULL,
    [PfNorm]          MONEY           CONSTRAINT [DF__Def__PfNorm__6B7ABB94_copy] DEFAULT ((0)) NULL,
    [Op]              INT             CONSTRAINT [DF__Def__Op__0FB81C0A_copy] DEFAULT ((0)) NULL,
    [dstAddr]         VARCHAR (200)   NULL,
    [wostamp]         BIT             CONSTRAINT [DF__Def__wostamp__62DA889B_copy] DEFAULT ((0)) NULL,
    [SumFriz]         BIT             CONSTRAINT [DF__Def__SumFriz__63CEACD4_copy] DEFAULT ((0)) NULL,
    [SverTara]        DATETIME        NULL,
    [OborotIce]       MONEY           CONSTRAINT [DF__Def__OborotIce__2843D2B2_copy] DEFAULT ((0)) NULL,
    [Part]            DECIMAL (5, 2)  CONSTRAINT [DF__Def__Part__47A76F72_copy] DEFAULT ((0.7)) NULL,
    [Bank_ID]         SMALLINT        CONSTRAINT [DF__Def__Bank_ID__05F9A7A6_copy] DEFAULT ((0)) NULL,
    [LimitOver]       MONEY           CONSTRAINT [DF__Def__LimitOver__4EC96E4D_copy] DEFAULT ((0)) NULL,
    [Priority]        TINYINT         CONSTRAINT [DF__Def__Priority__2D887613_copy] DEFAULT ((0)) NULL,
    [NaklCopy]        TINYINT         CONSTRAINT [DF__Def__NaklCopy__22A0D34C_copy] DEFAULT ((2)) NULL,
    [brFullName]      VARCHAR (200)   NULL,
    [C1Code]          VARCHAR (11)    NULL,
    [gln]             VARCHAR (13)    NULL,
    [LicScan]         DATETIME        NULL,
    [tradeArea]       NUMERIC (10, 2) NULL,
    [brag_id2]        INT             CONSTRAINT [DF__Def__brag_id2__2AB6F660_copy] DEFAULT ((0)) NULL,
    [Vmaster]         INT             CONSTRAINT [DF__Def__Vmaster__4476C863_copy] DEFAULT ((0)) NULL,
    [NDPret]          DATETIME        NULL,
    [NDPretBack]      DATETIME        NULL,
    [Email]           VARCHAR (100)   NULL,
    [Ncod]            INT             NULL,
    [NDCoord]         DATETIME        NULL,
    [dfID]            SMALLINT        DEFAULT ((0)) NULL,
    [upin]            INT             DEFAULT ((0)) NULL,
    [MainMaster]      INT             DEFAULT ((0)) NULL,
    [OKDP]            VARCHAR (20)    NULL,
    [gpRegCode]       VARCHAR (3)     NULL,
    [gpAddr_city]     VARCHAR (30)    NULL,
    [gpAddr_NasPunct] VARCHAR (30)    NULL,
    [gpAddr_Street]   VARCHAR (30)    NULL,
    [gpAddr_House]    VARCHAR (5)     NULL,
    [gpAddr_Corp]     VARCHAR (5)     NULL,
    [gpAddr_Room]     VARCHAR (5)     NULL,
    [p_id]            INT             DEFAULT ((0)) NOT NULL,
    [OborotPf]        MONEY           NULL,
    [point_ID]        INT             DEFAULT ((0)) NULL,
    [OLD_Pin]         INT             NULL,
    PRIMARY KEY NONCLUSTERED ([pin] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Def_idx7]
    ON [dbo].[NEW_def]([Reg_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [Def_idx6]
    ON [dbo].[NEW_def]([Our_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [Def_idx5]
    ON [dbo].[NEW_def]([brAg_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [Def_idx4]
    ON [dbo].[NEW_def]([tip] ASC);


GO
CREATE NONCLUSTERED INDEX [Def_idx3]
    ON [dbo].[NEW_def]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [Def_idx2]
    ON [dbo].[NEW_def]([Actual] ASC);


GO
CREATE NONCLUSTERED INDEX [Def_idx]
    ON [dbo].[NEW_def]([Master] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код сотрудника', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'p_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код региона, например, 36-Воронеж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpRegCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ОКДП', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'OKDP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'=Master, если Master>0, иначе =pin', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'MainMaster';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'универсальный код. См.проц.SaveUPin', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'upin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Формат точки, см.табл.DefFormat', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'dfID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата, время последнего обновления координат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'NDCoord';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код поставщика (для связи с Vendors)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Ncod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'E-mail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Претензия возвращена', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'NDPretBack';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отправлена претензия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'NDPret';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код точки-мастера виртуальной сети', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Vmaster';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Доп.агент покупателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brag_id2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Торговая площадь, м*м', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'tradeArea';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата сканирования договора в архиве', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'LicScan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GLN', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gln';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код 1С', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'C1Code';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полное наименование контрагента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brFullName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К удалению (Кол-во экземпляров накладных)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'NaklCopy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Приоритет торговой точки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Priority';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Лимит просроченной дебиторской задолженности, после которого продажи запрещены', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'LimitOver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код банка через который идут платежи от точки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Bank_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'% агента при расчете зарплаты', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Part';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оборот по мороженому', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'OborotIce';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата сверки тары', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'SverTara';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 - нормативы продаж по мороженому и п/ф сложены вместе', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'SumFriz';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Не требуется печать', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'wostamp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адрес доставки/почтовый', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'dstAddr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оператор заводивший', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индив. норматив продаж П/Ф, или 0, если общий', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'PfNorm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индив. норматив продаж мороженого,или 0, если общий', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'IceNorm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для бонусных клинтов не проверяется ИНН и ОГРН (А5)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Bonus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата последней сверки оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'LastFrizSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ставка зарплаты для W_Price3_SQL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Zarp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'До этого дня холодильники полуфабрикатов (PF, prepared food) не учитываются в расчете зарплаты.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'SkipPf';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'До этого дня холодильники мороженого не учитываются в расчете зарплаты.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'SkipIce';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время доставки ДО', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'TmPost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сотрудник фирмы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Worker';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Безналичный расчет', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'BNFlg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Не использовать минимальную наценку', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'DisMinEXTRA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата выдачи ОГРН', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'OGRNDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время работы клиента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'tmWork';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Перерыв', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'tmDin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ОГРН', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'OGRN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Блокировка отделом дебиторской задолженности', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Debit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Агентская группа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Ag_GRP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плательщик НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'NDSFlg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ОКПО2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'OKPO2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ОКПО', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'OKPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Предыдущий агент', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'PrevAgID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Формат торговой точки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Fmt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Грузоотправитель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'GrOt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип сети', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'NetType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Torg12';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Короткое название', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'ShortFam';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Период сверки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'PeriodSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата последней сверки дебиторки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'LastSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Участвует ли в продажах приоритетного товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Prior';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Нужна ли сверка оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'NeedSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Область', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Obl_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Район', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Rn_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логистический регион', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Reg_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код бухгалтера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Buh_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Организация', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Our_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код головного магазина (для сетей)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Master';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оборот', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Oborot';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Контактное лицо', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Contact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата заведения точки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'LicDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Срок действия договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'LicSrok';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Заключавший договор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'LicWho';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор №', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'LicNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наценка/скидка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Extra';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Заблокирован', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Disab';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Действующий', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Actual';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Срок консигнации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Srok';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полный пакет документов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'FullDocs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Координата Y', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'PosY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Координата X', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'PosX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Лимит продаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Limit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата внесения примечания', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'RemarkDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон юр.лица', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон фактический', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование К УДАЛЕНИЮ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'Fam';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код агента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brAg_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'КПП юр.лица', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brKpp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИНН юр.лица', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brInn';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БИК юр.лица', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brBik';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Банк юр.лица', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brBank';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К/С юридический', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brCs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Р/С юридический', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brRs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адрес юридический', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brAddr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс юр.лица', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brIndex';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование юр.лица', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'brName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'КПП грузополучателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpKpp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИНН грузополучателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpInn';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БИК грузополучателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpBik';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Банк грузополучателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpBank';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К/С грузополучателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpCs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Р/С грузополучателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpRs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адрес фактический', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpAddr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Индекс фактический', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpIndex';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование фактическое/грузополучателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'gpName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип (покупатели - 1)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'tip';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_def', @level2type = N'COLUMN', @level2name = N'pin';

