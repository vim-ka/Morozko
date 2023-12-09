CREATE TABLE [dbo].[SertifStockEntry] (
    [EntryID]         INT           IDENTITY (1, 1) NOT NULL,
    [guid]            VARCHAR (255) NULL,
    [uuid]            VARCHAR (255) NULL,
    [vetDocumentUuid] VARCHAR (255) NULL,
    [active]          BIT           NULL,
    [last]            BIT           NULL,
    [status]          SMALLINT      NULL,
    [createDate]      DATETIME      NULL,
    [updateDate]      DATETIME      NULL,
    [entryNumber]     VARCHAR (255) NULL,
    [productType]     SMALLINT      NULL,
    [productGuid]     VARCHAR (255) NULL,
    [productUuid]     VARCHAR (255) NULL,
    [SubProductGuid]  VARCHAR (255) NULL,
    [SubProductUuid]  VARCHAR (255) NULL,
    [productItemGuid] VARCHAR (255) NULL,
    [productItemUuid] VARCHAR (255) NULL,
    [volume]          FLOAT (53)    NULL,
    [unitGuid]        VARCHAR (255) NULL,
    [unitUuid]        VARCHAR (255) NULL,
    [prodFirstDate]   DATETIME      NULL,
    [prodSecondDate]  DATETIME      NULL,
    [expFirstDate]    DATETIME      NULL,
    [expSecondDate]   DATETIME      NULL,
    [perishable]      BIT           NULL,
    [lowGradeCargo]   BIT           NULL,
    [countryGuid]     VARCHAR (255) NULL,
    [countryUuid]     VARCHAR (255) NULL,
    [VetDocID]        INT           NULL,
    [StartID]         INT           NULL,
    [EnterpriseGuid]  VARCHAR (255) NULL,
    CONSTRAINT [PK_SERTIFSTOCKENTRY] PRIMARY KEY NONCLUSTERED ([EntryID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SertifStockEntry_uuid]
    ON [dbo].[SertifStockEntry]([uuid] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_SertifStockEntry_guid]
    ON [dbo].[SertifStockEntry]([guid] ASC);


GO
CREATE NONCLUSTERED INDEX [Relationship_1_FK]
    ON [dbo].[SertifStockEntry]([VetDocID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Справочник записей складского журнала', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifStockEntry';

