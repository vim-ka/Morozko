CREATE TABLE [dbo].[NFStage] (
    [id]   INT           IDENTITY (1, 1) NOT NULL,
    [name] VARCHAR (128) NULL,
    [ord]  INT           DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

