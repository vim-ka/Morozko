CREATE TABLE [db_FarLogistic].[dlLoadingNorm] (
    [IDdlVehicles]    INT NULL,
    [IDdlLoadingUnit] INT NULL,
    [Count]           INT NULL,
    CONSTRAINT [dlLoadingNorm_uq_dlLoadingNorm] UNIQUE NONCLUSTERED ([IDdlVehicles] ASC, [IDdlLoadingUnit] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Величина загрузки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlLoadingNorm', @level2type = N'COLUMN', @level2name = N'Count';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификатор единицы загрузки', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlLoadingNorm', @level2type = N'COLUMN', @level2name = N'IDdlLoadingUnit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Идентификато ТС', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlLoadingNorm', @level2type = N'COLUMN', @level2name = N'IDdlVehicles';

