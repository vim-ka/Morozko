CREATE TABLE [dbo].[SertifFirms2] (
    [ID]      INT           IDENTITY (1, 1) NOT NULL,
    [Our_ID]  INT           NULL,
    [BusGuid] VARCHAR (255) NULL,
    [BusName] VARCHAR (255) NULL,
    [EntGuid] VARCHAR (255) NULL,
    CONSTRAINT [PK_SertifFirms2_ID_copy] PRIMARY KEY CLUSTERED ([ID] ASC)
);

