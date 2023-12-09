CREATE TABLE [dbo].[Orders] (
    [OrdID]          INT          NOT NULL,
    [ND]             DATETIME     NULL,
    [DateShp]        DATETIME     NULL,
    [TimeShp]        VARCHAR (8)  NULL,
    [DateComm]       DATETIME     NULL,
    [Ncod]           INT          NULL,
    [Op]             INT          NULL,
    [summaprice]     MONEY        NULL,
    [summacost]      MONEY        NULL,
    [Done]           TINYINT      CONSTRAINT [DF__Orders__Done__2779CBAB] DEFAULT ((0)) NULL,
    [Ncom]           INT          NULL,
    [Massa]          REAL         NULL,
    [Auto]           VARCHAR (20) NULL,
    [Driver]         VARCHAR (25) NULL,
    [Phone]          VARCHAR (15) NULL,
    [FromPl]         VARCHAR (30) NULL,
    [FactDateComm]   DATETIME     NULL,
    [PrichZader]     VARCHAR (20) NULL,
    [TmVygr]         DATETIME     NULL,
    [TmBeg]          DATETIME     NULL,
    [TmEnd]          DATETIME     NULL,
    [PrichNev]       VARCHAR (20) NULL,
    [NormaRazgr]     VARCHAR (10) NULL,
    [BegRazgr]       DATETIME     NULL,
    [EndRazgr]       DATETIME     NULL,
    [VetSv]          VARCHAR (10) NULL,
    [Sert]           VARCHAR (10) NULL,
    [KachUd]         VARCHAR (10) NULL,
    [Dostav]         BIT          DEFAULT ((0)) NULL,
    [A3id]           INT          DEFAULT ((0)) NULL,
    [DCK]            INT          NULL,
    [Contact]        VARCHAR (50) NULL,
    [ContactPhone]   VARCHAR (80) NULL,
    [Sertif]         BIT          NULL,
    [VetDoc]         BIT          DEFAULT ((0)) NULL,
    [dlDelivPointID] INT          NULL,
    [pin]            INT          NULL,
    [DocNom]         VARCHAR (30) NULL,
    [mhID]           INT          DEFAULT ((0)) NOT NULL,
    [ShipingCost]    MONEY        DEFAULT ((0)) NULL,
    CONSTRAINT [Orders_pk] PRIMARY KEY CLUSTERED ([OrdID] ASC),
    CONSTRAINT [Orders_fk] FOREIGN KEY ([dlDelivPointID]) REFERENCES [db_FarLogistic].[dlDelivPoint] ([dlDelivPointID]) ON UPDATE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость доставки груза', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'ShipingCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер документа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'DocNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код поставщика из Def', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Место погрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'dlDelivPointID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наличие ветдокументов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'VetDoc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наличие сертификатов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Sertif';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон контактного лица', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'ContactPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Контактное лицо', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Contact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор с контрагентом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для связи с A3Req', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'A3id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наша доставка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Dostav';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кач. удостоверение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'KachUd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сертификат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Sert';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'вет. свидетельство', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'VetSv';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'конец разгрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'EndRazgr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'начало разгрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'BegRazgr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'норма разгрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'NormaRazgr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'причина невыполнения графика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'PrichNev';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время окончания размещения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'TmEnd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время начала размещения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'TmBeg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время начала выгрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'TmVygr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'причина задержки ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'PrichZader';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'фактическая дата прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'FactDateComm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'место загрузки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'FromPl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'телефон', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'шофер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Driver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'машина', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Auto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер поставки ИД Comman', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Ncom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'заявка обработана', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Done';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'summacost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'summaprice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код поставщика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Ncod';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'планируемая дата прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'DateComm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время счет фактуры (отгрузки)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'TimeShp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата счет фактуры (отгрузки)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'DateShp';

