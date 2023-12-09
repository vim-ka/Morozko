CREATE TABLE [dbo].[SertifSubProduct] (
    [SubProductId] INT           IDENTITY (1, 1) NOT NULL,
    [guid]         VARCHAR (255) NULL,
    [uuid]         VARCHAR (255) NULL,
    [name]         VARCHAR (255) NULL,
    [code]         VARCHAR (255) NULL,
    [productGuid]  VARCHAR (255) NULL,
    [active]       BIT           NULL,
    [last]         BIT           NULL,
    CONSTRAINT [PK_SertifSubProduct_SubProductId_copy] PRIMARY KEY CLUSTERED ([SubProductId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Вид продукции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifSubProduct';

