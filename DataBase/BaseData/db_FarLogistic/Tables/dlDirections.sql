CREATE TABLE [db_FarLogistic].[dlDirections] (
    [OriginID]      INT NULL,
    [DestinationID] INT NULL,
    [Distance]      INT DEFAULT ((-1)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расстояние в метрах', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDirections', @level2type = N'COLUMN', @level2name = N'Distance';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код точки назанчения', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDirections', @level2type = N'COLUMN', @level2name = N'DestinationID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код точки отправления', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDirections', @level2type = N'COLUMN', @level2name = N'OriginID';

