CREATE TABLE [dbo].[NEW_FirmsConfig] (
    [Our_id]            NUMERIC (2)    NOT NULL,
    [OurName]           VARCHAR (60)   NULL,
    [OurADDR]           VARCHAR (100)  NULL,
    [OurINN]            VARCHAR (12)   NULL,
    [OurBIK]            VARCHAR (30)   NULL,
    [OurBANK]           VARCHAR (80)   NULL,
    [OurLICNO]          VARCHAR (25)   NULL,
    [OurLICWHO]         VARCHAR (40)   NULL,
    [OurLICSROK]        DATETIME       NULL,
    [OurADDRFIZ]        VARCHAR (100)  NULL,
    [OurRSCHET]         VARCHAR (20)   NULL,
    [OurCSCHET]         VARCHAR (20)   NULL,
    [Direktor]          VARCHAR (20)   NULL,
    [Glavbuh]           VARCHAR (20)   NULL,
    [Phone]             VARCHAR (60)   NULL,
    [Kpp]               VARCHAR (10)   NULL,
    [Inpoffset]         NUMERIC (10)   NULL,
    [Nds]               BIT            DEFAULT ((0)) NULL,
    [OKPO]              VARCHAR (10)   NULL,
    [OurFullName]       VARCHAR (101)  NULL,
    [CompRegName]       VARCHAR (20)   NULL,
    [Actual]            BIT            NULL,
    [OurAbbreviature]   VARCHAR (3)    NULL,
    [OKPO2]             VARCHAR (10)   NULL,
    [OKDP]              VARCHAR (20)   NULL,
    [OGRN]              VARCHAR (20)   NULL,
    [OGRNDate]          DATETIME       NULL,
    [OurAddr_City]      VARCHAR (20)   DEFAULT ('Воронеж') NULL,
    [OurAddr_Street]    VARCHAR (30)   NULL,
    [OurAddr_House]     VARCHAR (6)    NULL,
    [OurAddr_Room]      VARCHAR (5)    NULL,
    [OurAddrFiz_City]   VARCHAR (20)   DEFAULT ('Воронеж') NULL,
    [OurAddrFiz_Street] VARCHAR (30)   NULL,
    [OurAddrFiz_House]  VARCHAR (6)    NULL,
    [OurAddrFiz_Room]   VARCHAR (5)    NULL,
    [ouraddr_index]     VARCHAR (6)    NULL,
    [ouraddrFiz_index]  VARCHAR (6)    NULL,
    [GlavbuhDov]        VARCHAR (40)   NULL,
    [PosX]              NUMERIC (9, 6) NULL,
    [PosY]              NUMERIC (9, 6) NULL,
    [pin_]              INT            NULL,
    [FirmGroup]         SMALLINT       DEFAULT ((1)) NULL,
    [GlavbuhUIN]        INT            DEFAULT ((0)) NULL,
    [KassaVal]          MONEY          DEFAULT ((0)) NULL,
    [pin]               INT            NOT NULL,
    [VetCode]           INT            NULL,
    [OurLastDocNum]     VARCHAR (30)   NULL,
    [Old_OurID]         INT            NULL,
    CONSTRAINT [FirmsConfig_pk_copy] PRIMARY KEY CLUSTERED ([Our_id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Текущее значение кассы для организации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_FirmsConfig', @level2type = N'COLUMN', @level2name = N'KassaVal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Актуальные фирмы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_FirmsConfig', @level2type = N'COLUMN', @level2name = N'Actual';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имя компьютера с кассовым аппаратом соответствующей фирмы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NEW_FirmsConfig', @level2type = N'COLUMN', @level2name = N'CompRegName';

