CREATE TABLE [dbo].[SSdet] (
    [ssd]       INT             IDENTITY (1, 1) NOT NULL,
    [ssid]      INT             NULL,
    [datnom]    INT             NULL,
    [tekid]     INT             NULL,
    [Request]   DECIMAL (10, 2) NULL,
    [Fact]      DECIMAL (10, 3) NULL,
    [Price]     MONEY           NULL,
    [EffWeight] DECIMAL (12, 3) NULL,
    [skg]       INT             NULL,
    PRIMARY KEY CLUSTERED ([ssd] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Складская группа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSdet', @level2type = N'COLUMN', @level2name = N'skg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'вес товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSdet', @level2type = N'COLUMN', @level2name = N'EffWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Цена по накл', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSdet', @level2type = N'COLUMN', @level2name = N'Price';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фактически набрано', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSdet', @level2type = N'COLUMN', @level2name = N'Fact';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во по накл', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSdet', @level2type = N'COLUMN', @level2name = N'Request';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSdet', @level2type = N'COLUMN', @level2name = N'tekid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'№ накладной ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSdet', @level2type = N'COLUMN', @level2name = N'datnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id набранного товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SSdet', @level2type = N'COLUMN', @level2name = N'ssid';

