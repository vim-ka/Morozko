CREATE TABLE [RestMon].[rm_NoSales] (
    [Hitag] INT             NOT NULL,
    [Lim]   DECIMAL (12, 2) NULL,
    [perID] TINYINT         DEFAULT ((0)) NULL,
    [unID]  TINYINT         DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([Hitag] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ед.изм,см.rm_Units', @level0type = N'SCHEMA', @level0name = N'RestMon', @level1type = N'TABLE', @level1name = N'rm_NoSales', @level2type = N'COLUMN', @level2name = N'unID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Период, см. rm_Period', @level0type = N'SCHEMA', @level0name = N'RestMon', @level1type = N'TABLE', @level1name = N'rm_NoSales', @level2type = N'COLUMN', @level2name = N'perID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Нижний порог продаж за период', @level0type = N'SCHEMA', @level0name = N'RestMon', @level1type = N'TABLE', @level1name = N'rm_NoSales', @level2type = N'COLUMN', @level2name = N'Lim';

