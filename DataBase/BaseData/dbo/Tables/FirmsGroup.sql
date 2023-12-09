CREATE TABLE [dbo].[FirmsGroup] (
    [FirmsGroupID]   INT           NOT NULL,
    [FirmsGroupName] VARCHAR (100) NULL,
    [ExportDir]      VARCHAR (100) NULL,
    [ExportArc]      VARCHAR (100) NULL,
    [BatchFile]      VARCHAR (80)  NULL,
    [ShortName]      VARCHAR (30)  NULL,
    [KassaVal]       MONEY         DEFAULT ((0)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Текущее значение кассы для организации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FirmsGroup', @level2type = N'COLUMN', @level2name = N'KassaVal';

