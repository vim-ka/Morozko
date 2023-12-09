CREATE TABLE [dbo].[SertifVetDocument] (
    [VetDocID]             INT            IDENTITY (1, 1) NOT NULL,
    [uuid]                 VARCHAR (255)  NULL,
    [VSDnumber]            VARCHAR (50)   NULL,
    [issueSeries]          VARCHAR (255)  NULL,
    [issueNumber]          VARCHAR (255)  NULL,
    [issueDate]            DATETIME       NULL,
    [form]                 SMALLINT       NULL,
    [type]                 SMALLINT       NULL,
    [status]               SMALLINT       NULL,
    [ConsignorBusGuid]     VARCHAR (255)  NULL,
    [ConsignorBusUuid]     VARCHAR (255)  NULL,
    [ConsignorEntGuid]     VARCHAR (255)  NULL,
    [ConsignorEntUuid]     VARCHAR (255)  NULL,
    [ConsigneeBusGuid]     VARCHAR (255)  NULL,
    [ConsigneeBusUuid]     VARCHAR (255)  NULL,
    [ConsigneeEntGuid]     VARCHAR (255)  NULL,
    [ConsigneeEntUuid]     VARCHAR (255)  NULL,
    [transportType]        SMALLINT       NULL,
    [vehicleNumber]        VARCHAR (255)  NULL,
    [containerNumber]      VARCHAR (255)  NULL,
    [trailerNumber]        VARCHAR (255)  NULL,
    [transportStorageType] SMALLINT       NULL,
    [productType]          SMALLINT       NULL,
    [productGuid]          VARCHAR (255)  NULL,
    [productUuid]          VARCHAR (255)  NULL,
    [SubProductGuid]       VARCHAR (255)  NULL,
    [SubProductUuid]       VARCHAR (255)  NULL,
    [productItemGuid]      VARCHAR (255)  NULL,
    [productItemUuid]      VARCHAR (255)  NULL,
    [productItemName]      VARCHAR (255)  NULL,
    [globalId]             VARCHAR (255)  NULL,
    [code]                 VARCHAR (255)  NULL,
    [volume]               FLOAT (53)     NULL,
    [unitGuid]             VARCHAR (255)  NULL,
    [unitUuid]             VARCHAR (255)  NULL,
    [prodFirstDate]        DATETIME       NULL,
    [prodSecondDate]       DATETIME       NULL,
    [expFirstDate]         DATETIME       NULL,
    [expSecondDate]        DATETIME       NULL,
    [perishable]           BIT            NULL,
    [lowGradeCargo]        BIT            NULL,
    [countryGuid]          VARCHAR (255)  NULL,
    [countryUuid]          VARCHAR (255)  NULL,
    [producerID]           INT            NULL,
    [cargoInspected]       BIT            NULL,
    [cargoExpertized]      SMALLINT       NULL,
    [locationProsperity]   VARCHAR (255)  NULL,
    [specialMarks]         VARCHAR (8000) NULL,
    [EntryID]              INT            NULL,
    [purposeGuid]          VARCHAR (255)  NULL,
    [purposeUuid]          VARCHAR (255)  NULL,
    [TTNtype]              SMALLINT       NULL,
    [TTNSeries]            VARCHAR (255)  NULL,
    [TTNnum]               VARCHAR (255)  NULL,
    [TTNdate]              DATETIME       NULL,
    CONSTRAINT [PK_SERTIFVETDOCUMENT] PRIMARY KEY NONCLUSTERED ([VetDocID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SertifVetDocument_uuid]
    ON [dbo].[SertifVetDocument]([uuid] ASC);


GO
CREATE NONCLUSTERED INDEX [Relationship_2_FK]
    ON [dbo].[SertifVetDocument]([EntryID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Справочник ВСД', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifVetDocument';

