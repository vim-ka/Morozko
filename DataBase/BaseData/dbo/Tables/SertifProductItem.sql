CREATE TABLE [dbo].[SertifProductItem] (
    [ProductItemId]     INT           IDENTITY (1, 1) NOT NULL,
    [ProductItemGuid]   VARCHAR (255) NULL,
    [ProductItemUuid]   VARCHAR (255) NULL,
    [name]              VARCHAR (255) NULL,
    [globalID]          VARCHAR (255) NULL,
    [code]              VARCHAR (255) NULL,
    [productType]       SMALLINT      NULL,
    [productGuid]       VARCHAR (255) NULL,
    [productUuid]       VARCHAR (255) NULL,
    [subProductGuid]    VARCHAR (255) NULL,
    [subProductUuid]    VARCHAR (255) NULL,
    [correspondsToGost] BIT           NULL,
    [gost]              VARCHAR (255) NULL,
    [ProducerGuid]      VARCHAR (255) NULL,
    [OwnerGuid]         VARCHAR (255) NULL,
    [enterpriseGuid]    VARCHAR (255) NULL,
    [unitGuid]          VARCHAR (255) NULL,
    [unitUuid]          VARCHAR (255) NULL,
    [hitag]             INT           NULL,
    [active]            BIT           NULL,
    [last]              BIT           NULL,
    CONSTRAINT [PK_SertifProductItem_ProductItemId] PRIMARY KEY CLUSTERED ([ProductItemId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SertifProductItem_ProductItemUuid]
    ON [dbo].[SertifProductItem]([ProductItemUuid] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_SertifProductItem_ProductItemGuid]
    ON [dbo].[SertifProductItem]([ProductItemGuid] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование продукции в соответствии с номенклатурой производителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifProductItem';

