CREATE TABLE [dbo].[Exite_Clients] (
    [CLID]    SMALLINT     IDENTITY (1, 1) NOT NULL,
    [ClName]  VARCHAR (25) NULL,
    [ediID]   INT          NULL,
    [DCK]     INT          NULL,
    [ClGroup] INT          NULL,
    PRIMARY KEY CLUSTERED ([CLID] ASC)
);

