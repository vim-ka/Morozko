CREATE TABLE [dbo].[FrizContractTip] (
    [CTip]  TINYINT      NOT NULL,
    [CName] VARCHAR (40) NULL,
    UNIQUE NONCLUSTERED ([CTip] ASC)
);

