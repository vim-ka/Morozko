CREATE TABLE [dbo].[SertifProductType] (
    [ProductTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [type]          SMALLINT      NULL,
    [name]          VARCHAR (255) NULL,
    CONSTRAINT [PK_SertifProductType_ProductTypeId_copy] PRIMARY KEY CLUSTERED ([ProductTypeId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип продукции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifProductType';

