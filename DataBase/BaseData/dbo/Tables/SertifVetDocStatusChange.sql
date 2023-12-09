CREATE TABLE [dbo].[SertifVetDocStatusChange] (
    [DocStatusID]     INT            IDENTITY (1, 1) NOT NULL,
    [status]          SMALLINT       NULL,
    [userLogin]       VARCHAR (255)  NULL,
    [actualDateTime]  DATETIME       NULL,
    [reason]          VARCHAR (8000) NULL,
    [vetDocumentUuid] VARCHAR (255)  NULL,
    [VetDocID]        INT            NULL,
    CONSTRAINT [PK_SERTIFVETDOCSTATUS] PRIMARY KEY NONCLUSTERED ([DocStatusID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Relationship_5_FK]
    ON [dbo].[SertifVetDocStatusChange]([VetDocID] ASC);

