CREATE TABLE [dbo].[FrizerCond] (
    [CondID]   INT            NOT NULL,
    [CondName] VARCHAR (30)   NULL,
    [kfPrice]  NUMERIC (7, 3) NULL,
    CONSTRAINT [PK_FRIZERCOND] PRIMARY KEY NONCLUSTERED ([CondID] ASC)
);

