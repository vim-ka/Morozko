CREATE TABLE [dbo].[SertifVetDocumentOUT] (
    [ID]     INT           IDENTITY (1, 1) NOT NULL,
    [datnom] INT           NULL,
    [nvId]   INT           NULL,
    [uuid]   VARCHAR (255) NULL,
    [OurID]  INT           NULL,
    [nd]     DATETIME      DEFAULT (getdate()) NULL,
    [op]     INT           NULL,
    [host]   NCHAR (30)    DEFAULT (host_name()) NULL,
    CONSTRAINT [PK_SertifVetDocumentOUT_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

