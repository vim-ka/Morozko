CREATE TABLE [db_FarLogistic].[dlVehicleExpence] (
    [ExpenceID]     INT           IDENTITY (1, 1) NOT NULL,
    [ExpenceDate]   DATETIME      NULL,
    [ExpenceSum]    MONEY         NULL,
    [dlVehicleID]   INT           NULL,
    [ExpenceCom]    VARCHAR (500) NULL,
    [ExpenceListID] INT           NULL,
    [IsDel]         BIT           DEFAULT ((0)) NULL,
    [GroupsID]      INT           NULL,
    UNIQUE NONCLUSTERED ([ExpenceID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'комментарий', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehicleExpence', @level2type = N'COLUMN', @level2name = N'ExpenceCom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наименование ТС', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehicleExpence', @level2type = N'COLUMN', @level2name = N'dlVehicleID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'сумма', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehicleExpence', @level2type = N'COLUMN', @level2name = N'ExpenceSum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehicleExpence', @level2type = N'COLUMN', @level2name = N'ExpenceDate';

