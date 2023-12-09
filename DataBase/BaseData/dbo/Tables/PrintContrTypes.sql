CREATE TABLE [dbo].[PrintContrTypes] (
    [ContrType]     INT           IDENTITY (1, 1) NOT NULL,
    [ContrTypeName] VARCHAR (100) NULL,
    UNIQUE NONCLUSTERED ([ContrType] ASC)
);

