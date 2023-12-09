CREATE TABLE [dbo].[NFTip] (
    [id]   INT           IDENTITY (1, 1) NOT NULL,
    [name] VARCHAR (256) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

