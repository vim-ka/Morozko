CREATE TABLE [dbo].[FrizContrAgr] (
    [AgrID]   INT          IDENTITY (1, 1) NOT NULL,
    [AgrName] VARCHAR (20) NULL,
    UNIQUE NONCLUSTERED ([AgrID] ASC)
);

