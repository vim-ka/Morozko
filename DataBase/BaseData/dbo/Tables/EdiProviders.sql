CREATE TABLE [dbo].[EdiProviders] (
    [ediID]   INT          IDENTITY (1, 1) NOT NULL,
    [ediName] VARCHAR (50) NULL,
    UNIQUE NONCLUSTERED ([ediID] ASC)
);

