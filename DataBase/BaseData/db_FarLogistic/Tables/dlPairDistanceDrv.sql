CREATE TABLE [db_FarLogistic].[dlPairDistanceDrv] (
    [IDRow]             INT IDENTITY (1, 1) NOT NULL,
    [IDDrv]             INT NULL,
    [MarshID]           INT NULL,
    [FinishPointNumber] INT NULL,
    [KM]                INT NULL,
    UNIQUE NONCLUSTERED ([IDRow] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Километраж', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPairDistanceDrv', @level2type = N'COLUMN', @level2name = N'KM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер второй точки пары', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPairDistanceDrv', @level2type = N'COLUMN', @level2name = N'FinishPointNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер маршрута', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPairDistanceDrv', @level2type = N'COLUMN', @level2name = N'MarshID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код водителя', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlPairDistanceDrv', @level2type = N'COLUMN', @level2name = N'IDDrv';

