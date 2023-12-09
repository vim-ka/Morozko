CREATE TABLE [dbo].[SkladLoadArea] (
    [LaID]   INT           IDENTITY (1, 1) NOT NULL,
    [LaName] VARCHAR (200) NULL,
    CONSTRAINT [PK_SkladLoadArea_LaID] PRIMARY KEY CLUSTERED ([LaID] ASC)
);

