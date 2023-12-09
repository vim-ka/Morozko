CREATE TABLE [dbo].[RentabCalcVid] (
    [id]   INT          IDENTITY (1, 1) NOT NULL,
    [name] VARCHAR (64) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

