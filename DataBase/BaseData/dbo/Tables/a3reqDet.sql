CREATE TABLE [dbo].[a3reqDet] (
    [a3id0]     INT             IDENTITY (1, 1) NOT NULL,
    [a3id]      INT             NOT NULL,
    [hitag]     INT             NULL,
    [price]     MONEY           NULL,
    [cost]      MONEY           NULL,
    [kol]       INT             NULL,
    [sert_id]   INT             NULL,
    [minp]      INT             NULL,
    [mpu]       INT             NULL,
    [dater]     DATETIME        NULL,
    [srokh]     DATETIME        NULL,
    [country]   VARCHAR (15)    NULL,
    [sklad]     SMALLINT        NULL,
    [summacost] MONEY           NULL,
    [BasePrice] MONEY           NULL,
    [Name]      VARCHAR (90)    NULL,
    [FName]     VARCHAR (100)   NULL,
    [Ngrp]      INT             NULL,
    [Locked]    BIT             NULL,
    [OnlyBox]   BIT             NULL,
    [NDS]       INT             NULL,
    [NCountry]  INT             NULL,
    [MeasID]    INT             NULL,
    [OnlyBase]  BIT             NULL,
    [Netto]     DECIMAL (12, 3) NULL,
    [Brutto]    DECIMAL (12, 3) NULL,
    [Weight]    DECIMAL (12, 3) NULL,
    [Storage]   INT             NULL,
    [Level]     INT             NULL,
    [Index]     INT             NULL,
    [NLine]     INT             NULL,
    [Depth]     INT             NULL,
    [Volum]     DECIMAL (12, 3) NULL,
    [Gtd]       VARCHAR (30)    NULL,
    [AddrID]    VARCHAR (1)     NULL,
    [VolMinP]   DECIMAL (12, 5) NULL,
    [TempVol]   FLOAT (53)      DEFAULT ((0)) NULL,
    [Clone]     TINYINT         DEFAULT ((0)) NULL,
    [CloneMain] BIT             DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([a3id0] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Главная строка в клоне', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'CloneMain';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ клона', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Clone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Темп продаж куб.м./день', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'TempVol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'объем мин партии', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'VolMinP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адресное хранение - ключ к т.AddrSpace', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'AddrID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер гтд', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Gtd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Объем', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Volum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Глубина', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Depth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ряд', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'NLine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'полка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Index';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'этаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Level';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'стеллаж', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Storage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'вес', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Weight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'брутто', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Brutto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'нетто', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Netto';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'использовать только базовые единицы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'OnlyBase';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'единицы измерения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'MeasID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код страна производитель', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'NCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'НДС', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'NDS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Только в коробках7', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'OnlyBox';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'заблокировано или продажа только опт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Locked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код группы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Ngrp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'полное наименование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'FName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наименование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена 1 единицы товара7', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'BasePrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'общая сумма прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'summacost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'склад', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'sklad';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'страна', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'country';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'срок хранения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'srokh';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата поставки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'dater';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'количество поддонов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'mpu';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'минимальная партия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'minp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер сертификата', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'sert_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'количество ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'kol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цена продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'price';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ид прихода', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'a3reqDet', @level2type = N'COLUMN', @level2name = N'a3id';

