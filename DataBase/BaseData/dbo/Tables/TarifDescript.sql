CREATE TABLE [dbo].[TarifDescript] (
    [Tarif_id]       INT           IDENTITY (1, 1) NOT NULL,
    [Tarif_descript] VARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([Tarif_id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица описания тарифов на перевозку грузов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TarifDescript';

