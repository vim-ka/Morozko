CREATE TABLE [db_FarLogistic].[dlVehicles] (
    [dlVehiclesID]     INT          IDENTITY (44, 1) NOT NULL,
    [dlVehTypeID]      INT          NULL,
    [dlMainVehID]      INT          NULL,
    [Model]            VARCHAR (50) NULL,
    [RegNom]           CHAR (15)    NULL,
    [NormFuelSpend]    FLOAT (53)   NULL,
    [NormDepreciation] MONEY        NULL,
    [isDel]            BIT          DEFAULT ((0)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Норма амортизации', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehicles', @level2type = N'COLUMN', @level2name = N'NormDepreciation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Норма расходов топлива', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehicles', @level2type = N'COLUMN', @level2name = N'NormFuelSpend';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Регистрационный номер', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehicles', @level2type = N'COLUMN', @level2name = N'RegNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Модель, марка', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehicles', @level2type = N'COLUMN', @level2name = N'Model';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Основое ТС (для прицепов)', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehicles', @level2type = N'COLUMN', @level2name = N'dlMainVehID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип ТС', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehicles', @level2type = N'COLUMN', @level2name = N'dlVehTypeID';

