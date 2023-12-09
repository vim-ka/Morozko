CREATE TABLE [dbo].[NEW_tdVi] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [ND]             DATETIME        NULL,
    [STARTID]        INT             NOT NULL,
    [NCOM]           INT             NULL,
    [NCOD]           INT             NULL,
    [DATEPOST]       DATETIME        NULL,
    [PRICE]          DECIMAL (13, 5) NULL,
    [START]          DECIMAL (12, 3) NULL,
    [STARTTHIS]      DECIMAL (12, 3) NULL,
    [HITAG]          INT             NULL,
    [SKLAD]          SMALLINT        NULL,
    [COST]           DECIMAL (13, 5) NULL,
    [NALOG5]         DECIMAL (1)     NULL,
    [MINP]           INT             CONSTRAINT [DF__tdVi__MINP__6F0C20AD_copy] DEFAULT ((1)) NOT NULL,
    [MPU]            INT             CONSTRAINT [DF__tdVi__MPU__700044E6_copy] DEFAULT ((1)) NOT NULL,
    [SERT_ID]        INT             NULL,
    [RANG]           CHAR (1)        NULL,
    [MORN]           DECIMAL (12, 3) CONSTRAINT [DF__Vi__MORN__0AF29B96_copy] DEFAULT ((0)) NOT NULL,
    [SELL]           DECIMAL (12, 3) CONSTRAINT [DF__Vi__SELL__0BE6BFCF_copy] DEFAULT ((0)) NOT NULL,
    [ISPRAV]         DECIMAL (12, 3) CONSTRAINT [DF__Vi__ISPRAV__0CDAE408_copy] DEFAULT ((0)) NOT NULL,
    [REMOV]          DECIMAL (12, 3) CONSTRAINT [DF__Vi__REMOV__0DCF0841_copy] DEFAULT ((0)) NOT NULL,
    [BAD]            DECIMAL (12, 3) CONSTRAINT [DF__Vi__BAD__0EC32C7A_copy] DEFAULT ((0)) NOT NULL,
    [DATER]          DATETIME        NULL,
    [SROKH]          DATETIME        NULL,
    [COUNTRY]        VARCHAR (50)    NULL,
    [REZERV]         DECIMAL (12, 3) CONSTRAINT [DF__tdVi__REZERV__4C9641C1_copy] DEFAULT ((0)) NULL,
    [UNITS]          VARCHAR (3)     NULL,
    [LOCKED]         BIT             CONSTRAINT [DF__tdVi__LOCKED__7385F1B0_copy] DEFAULT ((0)) NULL,
    [NCOUNTRY]       DECIMAL (3)     NULL,
    [GTD]            VARCHAR (100)   NULL,
    [VITR]           DECIMAL (12, 3) CONSTRAINT [DF__Vi__VITR__0FB750B3_copy] DEFAULT ((0)) NULL,
    [OUR_ID]         SMALLINT        CONSTRAINT [DF__Vi__OUR_ID__10AB74EC_copy] DEFAULT ((7)) NULL,
    [WEIGHT]         DECIMAL (12, 3) CONSTRAINT [DF__Vi__WEIGHT__119F9925_copy] DEFAULT ((0)) NOT NULL,
    [SaveDate]       DATETIME        CONSTRAINT [DF__tdVi__SaveDate__4D9F7493_copy] DEFAULT (getdate()) NULL,
    [MeasId]         TINYINT         CONSTRAINT [DF__tdVi__Meas__7128A7F2_copy] DEFAULT ((2)) NULL,
    [OnlyMinP]       BIT             CONSTRAINT [DF__tdVi__OnlyMinP__74F938D6_copy] DEFAULT ((0)) NULL,
    [AddrID]         INT             CONSTRAINT [DF__tdVi__AddrID__7CE53EB8_copy] DEFAULT ((0)) NULL,
    [DCK]            INT             NOT NULL,
    [ProducerID]     INT             NULL,
    [CountryID]      INT             NULL,
    [wsID]           TINYINT         CONSTRAINT [DF__tdVi__wsID__1B94AE61_copy] DEFAULT ((1)) NULL,
    [safeCust]       BIT             CONSTRAINT [DF__tdVi__safeCust__2BB60791_copy] DEFAULT ((0)) NULL,
    [Price_old]      DECIMAL (13, 2) NULL,
    [LockID]         INT             CONSTRAINT [DF__tdVi__LockExpDat__70E025DD_copy] DEFAULT ((0)) NULL,
    [PinOwner]       INT             CONSTRAINT [DF__tdVi__PinOwner__0B34F4BD_copy] DEFAULT ((0)) NULL,
    [DCKOwner]       INT             CONSTRAINT [DF__tdVi__DCKOwner__0C2918F6_copy] DEFAULT ((0)) NULL,
    [pin]            INT             CONSTRAINT [DF__tdVi__pin__66E285AE_copy] DEFAULT ((0)) NULL,
    [AutoID]         INT             DEFAULT ((0)) NULL,
    [Id_Old]         INT             NULL,
    [ProducerCodeId] INT             NULL,
    [Rest]           AS              (((([morn]-[sell])+[isprav])-[remov])+[bad]),
    [UnID]           TINYINT         DEFAULT ((0)) NOT NULL,
    [Unid2]          TINYINT         DEFAULT ((0)) NOT NULL,
    [KU]             DECIMAL (14, 7) DEFAULT ((1.0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [tdVi_ck_copy] CHECK ([DCK]<>(0)),
    CONSTRAINT [tdVi_fk_copy] FOREIGN KEY ([LockID]) REFERENCES [dbo].[Lock] ([LockID]) ON UPDATE SET DEFAULT
);


GO
CREATE NONCLUSTERED INDEX [tdVi_idx3]
    ON [dbo].[NEW_tdVi]([HITAG] ASC);


GO
CREATE NONCLUSTERED INDEX [tdVi_idx2]
    ON [dbo].[NEW_tdVi]([NCOD] ASC);


GO
CREATE NONCLUSTERED INDEX [tdVi_idx]
    ON [dbo].[NEW_tdVi]([NCOM] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ед.изм. (см.табл.Units)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'UnID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Остаток товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'Rest';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код поставщика из DEF', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'идентификатор договора владельца', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'DCKOwner';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'идентификатор владельца', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'PinOwner';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Уровень блокировки (0 разблокир, 3 приход, 4 дата)- ссылка на справочник Lock', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'LockID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ответ. хранение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'safeCust';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Состояние товара - WaresStat', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'wsID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ид страны', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'CountryID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ид Производителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'ProducerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор с контрагентом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID aдреса хранения товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'AddrID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1, если продажа только мин.партиями (через приход проходит по умолчанию из табл SkladList)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'OnlyMinP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Единицы измерения по умолчанию', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'MeasId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата внесения строки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'SaveDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'вес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'WEIGHT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наша фирма', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'OUR_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'гтд', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'GTD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'поставщик', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'NCOUNTRY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'заблокирована', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'LOCKED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К УДАЛЕНИЮ страна после выяснения почему пропадают CountryId ProducerID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'COUNTRY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата окончания срока годности', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'SROKH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата выработки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'DATER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'возврат поставщику', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'REMOV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'корректировка остатка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'ISPRAV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'продано', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'SELL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'остаток на утро', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'MORN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К УДАЛЕНИЮ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'RANG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сертификат номер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'SERT_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'мпу', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'MPU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'мин п', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'MINP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'К УДАЛЕНИЮ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'NALOG5';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'COST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'склад', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'SKLAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код номенклатуры', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'HITAG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'начальное кол-во по ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'STARTTHIS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'стартовое кол-во по этой строчке (ID)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'START';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'PRICE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата поставки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'DATEPOST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'NCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'NCOM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'начальный ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'STARTID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_tdVi', @level2type = N'COLUMN', @level2name = N'ND';

