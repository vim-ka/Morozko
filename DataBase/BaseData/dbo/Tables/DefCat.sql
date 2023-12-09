CREATE TABLE [dbo].[DefCat] (
    [CatID]   INT          IDENTITY (1, 1) NOT NULL,
    [CatName] VARCHAR (30) NULL,
    UNIQUE NONCLUSTERED ([CatID] ASC)
);

