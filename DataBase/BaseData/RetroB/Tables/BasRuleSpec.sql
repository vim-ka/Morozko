CREATE TABLE [RetroB].[BasRuleSpec] (
    [id]     INT IDENTITY (1, 1) NOT NULL,
    [ruleid] INT NULL,
    [bpmid]  INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

