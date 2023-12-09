CREATE TABLE [dbo].[AgentsInfo] (
    [aik]   INT      IDENTITY (1, 1) NOT NULL,
    [nd]    DATETIME DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [tm]    CHAR (8) DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [ag_id] INT      NULL,
    [info]  INT      NULL,
    UNIQUE NONCLUSTERED ([aik] ASC)
);


GO
CREATE NONCLUSTERED INDEX [AgentsInfo_idx2]
    ON [dbo].[AgentsInfo]([ag_id] ASC);


GO
CREATE NONCLUSTERED INDEX [AgentsInfo_idx]
    ON [dbo].[AgentsInfo]([nd] ASC);

