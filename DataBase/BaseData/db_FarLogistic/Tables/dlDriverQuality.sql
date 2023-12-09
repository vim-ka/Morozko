CREATE TABLE [db_FarLogistic].[dlDriverQuality] (
    [IDQuality]   INT          IDENTITY (1, 1) NOT NULL,
    [QualityName] VARCHAR (20) NULL,
    [KMPrice]     MONEY        NULL,
    UNIQUE NONCLUSTERED ([IDQuality] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ставка', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDriverQuality', @level2type = N'COLUMN', @level2name = N'KMPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование', @level0type = N'SCHEMA', @level0name = N'db_FarLogistic', @level1type = N'TABLE', @level1name = N'dlDriverQuality', @level2type = N'COLUMN', @level2name = N'QualityName';

