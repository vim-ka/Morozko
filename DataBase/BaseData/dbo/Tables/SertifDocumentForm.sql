CREATE TABLE [dbo].[SertifDocumentForm] (
    [DocumentFormID] INT           IDENTITY (1, 1) NOT NULL,
    [form]           SMALLINT      NULL,
    [name]           VARCHAR (255) NULL,
    CONSTRAINT [PK_SertifDocumentType_DocumentTypeID_copy] PRIMARY KEY CLUSTERED ([DocumentFormID] ASC)
);

