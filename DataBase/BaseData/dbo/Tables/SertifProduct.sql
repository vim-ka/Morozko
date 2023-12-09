CREATE TABLE [dbo].[SertifProduct] (
    [ProductId]   INT           IDENTITY (1, 1) NOT NULL,
    [guid]        VARCHAR (255) NULL,
    [uuid]        VARCHAR (255) NULL,
    [name]        VARCHAR (255) NULL,
    [code]        VARCHAR (255) NULL,
    [productType] SMALLINT      NULL,
    [active]      BIT           NULL,
    [last]        BIT           NULL,
    CONSTRAINT [PK_SertifProduct_ProductId_copy] PRIMARY KEY CLUSTERED ([ProductId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Продукция', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifProduct';

