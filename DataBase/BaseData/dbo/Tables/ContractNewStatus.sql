CREATE TABLE [dbo].[ContractNewStatus] (
    [id]     INT          IDENTITY (1, 1) NOT NULL,
    [stname] VARCHAR (50) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

