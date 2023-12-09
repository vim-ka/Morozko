CREATE TABLE [dbo].[SertifFirms] (
    [ID]     INT           IDENTITY (1, 1) NOT NULL,
    [Our_id] INT           NULL,
    [guid]   VARCHAR (255) NULL,
    [name]   VARCHAR (255) NULL,
    CONSTRAINT [PK_SertifFirms_ID_copy] PRIMARY KEY CLUSTERED ([ID] ASC)
);

