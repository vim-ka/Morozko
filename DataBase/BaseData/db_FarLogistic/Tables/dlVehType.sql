CREATE TABLE [db_FarLogistic].[dlVehType] (
    [dlVehTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [VehType]     VARCHAR (50) NULL,
    CONSTRAINT [dlVehType_pk_dlVehType] PRIMARY KEY CLUSTERED ([dlVehTypeID] ASC),
    UNIQUE NONCLUSTERED ([dlVehTypeID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип ТС', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlVehType', @level2type = N'COLUMN', @level2name = N'VehType';

