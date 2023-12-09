CREATE TABLE [dbo].[RentabRegions] (
    [id]   INT          IDENTITY (1, 1) NOT NULL,
    [name] VARCHAR (64) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

