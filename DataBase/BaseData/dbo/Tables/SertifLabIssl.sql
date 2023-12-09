CREATE TABLE [dbo].[SertifLabIssl] (
    [IdIs]      INT            IDENTITY (1, 1) NOT NULL,
    [LabIssl]   VARCHAR (8000) NULL,
    [IdVetSvid] INT            DEFAULT ((0)) NULL,
    [IsDel]     BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SertifLabIssl_IdIs_copy] PRIMARY KEY CLUSTERED ([IdIs] ASC)
);

