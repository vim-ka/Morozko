CREATE TABLE [dbo].[SMoveSkDet] (
    [mdId]   INT IDENTITY (1, 1) NOT NULL,
    [moveId] INT NOT NULL,
    [hitag]  INT NULL,
    [SKol]   INT DEFAULT ((0)) NULL,
    [FKol]   INT DEFAULT ((0)) NULL,
    CONSTRAINT [SMoveSkDet_pk] PRIMARY KEY CLUSTERED ([mdId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во товара пришедшего на перемещаемый склад', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMoveSkDet', @level2type = N'COLUMN', @level2name = N'FKol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во товара набранного для перемещения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SMoveSkDet', @level2type = N'COLUMN', @level2name = N'SKol';

