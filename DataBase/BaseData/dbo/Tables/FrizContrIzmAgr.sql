CREATE TABLE [dbo].[FrizContrIzmAgr] (
    [NomIzmAgr]  INT         IDENTITY (1, 1) NOT NULL,
    [ND]         DATETIME    DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]         VARCHAR (8) DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [ContractID] INT         NULL,
    [OldAgrID]   INT         NULL,
    [NewAgrID]   INT         NULL,
    [OP]         SMALLINT    NULL,
    UNIQUE NONCLUSTERED ([NomIzmAgr] ASC)
);

