CREATE TABLE [dbo].[CopyDef] (
    [cd]  INT IDENTITY (1, 1) NOT NULL,
    [pin] INT NULL,
    UNIQUE NONCLUSTERED ([cd] ASC)
);

