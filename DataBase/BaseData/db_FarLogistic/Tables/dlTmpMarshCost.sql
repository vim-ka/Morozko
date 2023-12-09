CREATE TABLE [db_FarLogistic].[dlTmpMarshCost] (
    [MarshID]   INT        NULL,
    [WorkID]    INT        NULL,
    [KM]        INT        NULL,
    [Cost]      MONEY      NULL,
    [CasherID]  INT        NULL,
    [PalCount]  INT        DEFAULT ((0)) NULL,
    [NewCost]   MONEY      NULL,
    [DotsCount] INT        DEFAULT ((0)) NULL,
    [delta]     AS         ([db_FarLogistic].[GetMarshStatisicCurrent]([WorkId],[MarshID])),
    [palWeight] FLOAT (53) DEFAULT ((0)) NOT NULL,
    [isFix]     BIT        DEFAULT ((0)) NOT NULL,
    [PalKMCost] MONEY      DEFAULT ((0)) NOT NULL,
    [dotCost]   MONEY      DEFAULT ((0)) NOT NULL,
    [minKM]     INT        DEFAULT ((0)) NOT NULL,
    [minKMCost] MONEY      DEFAULT ((0)) NOT NULL,
    [DepID]     INT        DEFAULT ((0)) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [dlTmpMarshCost_idx4]
    ON [db_FarLogistic].[dlTmpMarshCost]([DepID] ASC);


GO
CREATE NONCLUSTERED INDEX [dlTmpMarshCost_idx3]
    ON [db_FarLogistic].[dlTmpMarshCost]([MarshID] ASC, [WorkID] ASC);


GO
CREATE NONCLUSTERED INDEX [dlTmpMarshCost_idx2]
    ON [db_FarLogistic].[dlTmpMarshCost]([WorkID] ASC);


GO
CREATE NONCLUSTERED INDEX [dlTmpMarshCost_idx]
    ON [db_FarLogistic].[dlTmpMarshCost]([MarshID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ставка за точки сверх двух', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'dotCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ставка руб.км.паллета', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'PalKMCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'фиксированная ставка', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'isFix';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'!!!Вычисляемое поле', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'delta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'количество точек', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'DotsCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стооимость новый рассчет', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'NewCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во паллет', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'PalCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД плательщика', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'CasherID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'Cost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'пробег', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'KM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД работы', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'WorkID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ИД маршрута', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlTmpMarshCost', @level2type = N'COLUMN', @level2name = N'MarshID';

