CREATE TABLE [dbo].[SertifVetApiAccess] (
    [ID]       INT           IDENTITY (1, 1) NOT NULL,
    [Login]    VARCHAR (255) NULL,
    [Password] VARCHAR (255) NULL,
    [APIKey]   VARCHAR (255) NULL,
    [IssuerID] VARCHAR (255) NULL,
    [name]     VARCHAR (255) NULL,
    CONSTRAINT [PK_SertifVetApiAccess_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

