CREATE TABLE [dbo].[DefContractTip] (
    [ContrTip] INT          IDENTITY (1, 1) NOT NULL,
    [TipName]  VARCHAR (25) NULL,
    UNIQUE NONCLUSTERED ([ContrTip] ASC)
);

