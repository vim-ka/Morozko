CREATE TABLE [dbo].[SertifProducers] (
    [SpID]            INT           IDENTITY (1, 1) NOT NULL,
    [EnterpriseGuid]  VARCHAR (255) NULL,
    [vetDocumentUuid] VARCHAR (255) NULL,
    [Role]            INT           NULL,
    CONSTRAINT [PK_SERTIFPRODUCERS] PRIMARY KEY NONCLUSTERED ([SpID] ASC)
);

