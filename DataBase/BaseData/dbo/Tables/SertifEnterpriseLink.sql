CREATE TABLE [dbo].[SertifEnterpriseLink] (
    [ID]                 INT IDENTITY (1, 1) NOT NULL,
    [SertifenterpriseID] INT NULL,
    [pin]                INT NULL,
    CONSTRAINT [PK_SertifEnterpriseLink_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

