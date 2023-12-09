CREATE TABLE [dbo].[SertifPackingType] (
    [PackingTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [type]          VARCHAR (10)  NULL,
    [name]          VARCHAR (255) NULL,
    [englishname]   VARCHAR (255) NULL,
    CONSTRAINT [PK_SertifPackingType_PackingType_copy] PRIMARY KEY CLUSTERED ([PackingTypeID] ASC)
);

