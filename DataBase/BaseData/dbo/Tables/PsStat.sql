CREATE TABLE [dbo].[PsStat] (
    [StID]        INT          IDENTITY (1, 1) NOT NULL,
    [stName]      VARCHAR (60) NULL,
    [stShortName] VARCHAR (6)  NULL,
    UNIQUE NONCLUSTERED ([StID] ASC)
);

