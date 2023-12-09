CREATE TABLE [dbo].[SertifDefLink] (
    [ID]          INT IDENTITY (1, 1) NOT NULL,
    [SertifDefId] INT NULL,
    [pin]         INT NULL,
    CONSTRAINT [PK_SertifDefLink_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

