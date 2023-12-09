CREATE TABLE [dbo].[TarifGp] (
    [tgId]      INT          IDENTITY (1, 1) NOT NULL,
    [TarifType] VARCHAR (4)  NULL,
    [tarif_id]  INT          NULL,
    [Remark]    VARCHAR (25) NULL,
    [Pay]       MONEY        NULL,
    [vehType]   INT          NULL,
    [DepId]     INT          NULL,
    [trParam]   INT          NULL,
    PRIMARY KEY CLUSTERED ([tgId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Параматры:
код описания      параметер
   1                 -
   2            протяженность рейса, км
   3               кол-во торг точек
   4           год(дни непрерывного сотрудн.)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TarifGp', @level2type = N'COLUMN', @level2name = N'trParam';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код отдела', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TarifGp', @level2type = N'COLUMN', @level2name = N'DepId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'категория авто из табл vehType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TarifGp', @level2type = N'COLUMN', @level2name = N'vehType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата,руб (или коэффиц. для премиальн. части)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TarifGp', @level2type = N'COLUMN', @level2name = N'Pay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Параматры:
код описания      параметер
   1                 -
   2            протяженность рейса, км
   3               кол-во торг точек
   4           год(дни непрерывного сотрудн.)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TarifGp', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код описания (ключ из таблицы TarifDescription)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TarifGp', @level2type = N'COLUMN', @level2name = N'tarif_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'IP - тарификация по ИП
PHYS - тарификация по физ лицам', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TarifGp', @level2type = N'COLUMN', @level2name = N'TarifType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тарифы грузоперевозок', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TarifGp';

