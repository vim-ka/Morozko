CREATE TABLE [dbo].[SertifProductItemLink] (
    [ID]            INT IDENTITY (1, 1) NOT NULL,
    [ProductItemId] INT NULL,
    [hitag]         INT NULL,
    CONSTRAINT [PK_SertifProductItemLink_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

