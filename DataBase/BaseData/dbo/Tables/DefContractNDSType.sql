CREATE TABLE [dbo].[DefContractNDSType] (
    [dcnID] INT          IDENTITY (1, 1) NOT NULL,
    [type]  VARCHAR (20) NULL,
    UNIQUE NONCLUSTERED ([dcnID] ASC)
);

