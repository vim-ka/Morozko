CREATE TABLE [dbo].[PrintDocTypes] (
    [PDType]      INT           IDENTITY (1, 1) NOT NULL,
    [DocTypeName] VARCHAR (100) NULL,
    UNIQUE NONCLUSTERED ([PDType] ASC)
);

