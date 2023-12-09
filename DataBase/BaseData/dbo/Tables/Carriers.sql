CREATE TABLE [dbo].[Carriers] (
    [CrID]        INT           IDENTITY (1, 1) NOT NULL,
    [crName]      VARCHAR (100) NULL,
    [UrArrd]      VARCHAR (150) NULL,
    [FactAddr]    VARCHAR (150) NULL,
    [Phone]       VARCHAR (40)  NULL,
    [Bank_id]     INT           NULL,
    [crRs]        VARCHAR (20)  NULL,
    [crCs]        VARCHAR (20)  NULL,
    [crInn]       VARCHAR (12)  NULL,
    [crKpp]       VARCHAR (9)   NULL,
    [crOGRN]      VARCHAR (15)  NULL,
    [crORGNDate]  DATETIME      NULL,
    [Closed]      BIT           CONSTRAINT [DF__Carriers__Closed__34157811] DEFAULT ((0)) NULL,
    [BeginDate]   DATETIME      NULL,
    [DocNom]      VARCHAR (15)  NULL,
    [DocDate]     DATETIME      NULL,
    [DocDateFin]  DATETIME      NULL,
    [PhysPerson]  TINYINT       CONSTRAINT [DF__Carriers__PhysPe__37E608F5] DEFAULT ((0)) NULL,
    [crBik]       VARCHAR (9)   NULL,
    [RegistrNom]  VARCHAR (15)  NULL,
    [RegistrDate] DATETIME      NULL,
    [NDS]         BIT           CONSTRAINT [DF__Carriers__NDS__232AE331] DEFAULT ((0)) NULL,
    [pin]         INT           NULL,
    [ttID]        INT           DEFAULT ((2)) NULL,
    [p_id]        INT           DEFAULT ((-1)) NOT NULL,
    [Phone1]      VARCHAR (40)  NULL,
    PRIMARY KEY CLUSTERED ([CrID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип грузоперевозчика', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'ttID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'связка c Def', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'pin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Плательщик НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'NDS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Свидетельство о регистрации ИП (Дата выдачи)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'RegistrDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Свидетельство о регистрации ИП(Номер)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'RegistrNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'БИК', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'crBik';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 - грузоперевозчик (ООО или ИП)
1 - Физ лицо', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'PhysPerson';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата окончания договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'DocDateFin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата заключения договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'DocDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'DocNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата начала работы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'BeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'грузоперевозчик закрыт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'Closed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата выдачи ОГРН', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'crORGNDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ОГРН', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'crOGRN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'КПП', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'crKpp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИНН', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'crInn';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'корреспонд. счет', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'crCs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расчетный счет', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'crRs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Банк', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'Bank_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фактический адрес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'FactAddr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Юридический адрес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers', @level2type = N'COLUMN', @level2name = N'UrArrd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица грузоперевозчиков', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Carriers';

