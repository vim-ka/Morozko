CREATE TABLE [dbo].[Nomen_Log] (
    [id]             INT             IDENTITY (1, 1) NOT NULL,
    [hitag]          INT             NULL,
    [name]           VARCHAR (90)    NULL,
    [inactive]       BIT             DEFAULT ((0)) NULL,
    [nds]            TINYINT         NULL,
    [price]          DECIMAL (10, 2) DEFAULT ((0)) NULL,
    [cost]           DECIMAL (15, 5) DEFAULT ((0)) NULL,
    [minp]           DECIMAL (5)     DEFAULT ((1)) NULL,
    [mpu]            DECIMAL (5)     CONSTRAINT [DF__Nomen_Log__mpu__61349950] DEFAULT ((1)) NULL,
    [ngrp]           INT             NULL,
    [fname]          VARCHAR (100)   NULL,
    [emk]            DECIMAL (7, 3)  NULL,
    [egrp]           TINYINT         NULL,
    [sert_id]        DECIMAL (6)     NULL,
    [prior]          DATETIME        NULL,
    [barcode]        VARCHAR (20)    NULL,
    [barcodeMinP]    VARCHAR (20)    NULL,
    [MinW]           DECIMAL (10, 3) DEFAULT ((0)) NULL,
    [Netto]          DECIMAL (10, 3) DEFAULT ((0)) NULL,
    [Brutto]         DECIMAL (10, 3) DEFAULT ((0)) NULL,
    [MinEXTRA]       NUMERIC (6, 3)  DEFAULT ((10)) NULL,
    [Closed]         BIT             DEFAULT ((0)) NULL,
    [OnlyMinP]       BIT             DEFAULT ((0)) NULL,
    [MeasID]         TINYINT         DEFAULT ((2)) NULL,
    [Weight_b]       DECIMAL (10, 3) NULL,
    [flgWeight]      BIT             DEFAULT ((0)) NULL,
    [disab]          BIT             DEFAULT ((0)) NULL,
    [NCID]           INT             DEFAULT ((1)) NULL,
    [VolMinp]        FLOAT (53)      DEFAULT ((0)) NULL,
    [AddTag]         VARCHAR (10)    NULL,
    [KZarp]          DECIMAL (5, 2)  DEFAULT ((1)) NULL,
    [STM]            BIT             DEFAULT ((0)) NULL,
    [krep]           DECIMAL (7, 3)  NULL,
    [LastSkladID]    INT             NULL,
    [LastProducerID] INT             NULL,
    [LastCountryID]  INT             DEFAULT ((643)) NULL,
    [SafeCust]       BIT             DEFAULT ((0)) NULL,
    [NgrpOld]        INT             NULL,
    [ShelfLifeAdd]   INT             NULL,
    [ShelfLife]      INT             NULL,
    [Op]             INT             NULL,
    [date]           DATETIME        NULL,
    [DateCreate]     DATETIME        DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [price_old]      DECIMAL (10, 2) NULL,
    [user_id]        INT             NULL,
    [user_datetime]  DATETIME        NULL,
    [user_type]      VARCHAR (3)     NULL,
    [user_app_name]  VARCHAR (100)   NULL,
    [host_name]      VARCHAR (64)    DEFAULT (host_name()) NULL,
    [type]           INT             NULL,
    [DT]             DATETIME        DEFAULT (getdate()) NULL
);


GO
CREATE NONCLUSTERED INDEX [Nomen_Log_idx4]
    ON [dbo].[Nomen_Log]([minp] ASC);


GO
CREATE NONCLUSTERED INDEX [Nomen_Log_idx3]
    ON [dbo].[Nomen_Log]([id] ASC);


GO
CREATE NONCLUSTERED INDEX [Nomen_Log_idx2]
    ON [dbo].[Nomen_Log]([user_type] ASC);


GO
CREATE NONCLUSTERED INDEX [Nomen_Log_idx]
    ON [dbo].[Nomen_Log]([hitag] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена продажи до переоценки 1 апреля на 1 процент', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'price_old';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата Создания', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'DateCreate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'крайний оператор)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'Op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Срок годности в днях', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'ShelfLife';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ссылка на справочник Примечаний (откуда инфа о сроке годности)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'ShelfLifeAdd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ответ хранение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'SafeCust';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД страны', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'LastCountryID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД последнего производителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'LastProducerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид склада на который поступал товар при посл приходе', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'LastSkladID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'krep';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Собств.торг.марка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'STM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Коэфф.для расчета зарплаты агентов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'KZarp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Доп.код, напр. ЗВШ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'AddTag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объем МинП', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'VolMinp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для связи с NomenCat', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'NCID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Запрещен к продаже', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'disab';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'флаг для весового товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'flgWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вeс базовой единицы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'Weight_b';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'базовая единица', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'MeasID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 - продажа только мин.партиями', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'OnlyMinP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выведен из прайс-листа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'Closed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Минимальная наценка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'MinEXTRA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'брутто', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'Brutto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'нетто', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'Netto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'MinW';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'штрих код на коробке', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'barcodeMinP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'штрих код', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'barcode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'приоритетный товар', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'prior';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер сертификата', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'sert_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'egrp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'emk';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'полное наименование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'fname';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер группы товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'ngrp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во на поддоне', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'mpu';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'минимальная партия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'minp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена закупки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'price';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'nds';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'неактивная позиция (для заявки)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'inactive';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наименование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Nomen_Log', @level2type = N'COLUMN', @level2name = N'name';

