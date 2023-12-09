CREATE TABLE [dbo].[Marsh2CalcFact] (
    [sm]   MONEY NULL,
    [mhid] INT   NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'таблица для временных данных по маршрутам', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Marsh2CalcFact';

