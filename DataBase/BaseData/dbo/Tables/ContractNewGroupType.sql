CREATE TABLE [dbo].[ContractNewGroupType] (
    [id]     INT           IDENTITY (1, 1) NOT NULL,
    [grname] VARCHAR (128) NULL,
    [grday]  INT           NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

