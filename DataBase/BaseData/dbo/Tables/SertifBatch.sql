CREATE TABLE [dbo].[SertifBatch] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [batchID]         VARCHAR (255) NULL,
    [vetDocumentUuid] VARCHAR (255) NULL,
    [VetDocID]        INT           NULL,
    CONSTRAINT [PK_SERTIFBATCH_copy] PRIMARY KEY NONCLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Relationship_3_FK]
    ON [dbo].[SertifBatch]([VetDocID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Партия продукции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SertifBatch';

