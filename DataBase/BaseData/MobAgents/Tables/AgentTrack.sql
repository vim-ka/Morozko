CREATE TABLE [MobAgents].[AgentTrack] (
    [atID]  INT      IDENTITY (1, 1) NOT NULL,
    [ND]    DATETIME NULL,
    [TM]    CHAR (8) NULL,
    [ag_id] INT      NULL,
    PRIMARY KEY CLUSTERED ([atID] ASC)
);

