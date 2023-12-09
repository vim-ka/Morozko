CREATE TABLE [MobAgents].[AgentTrackDet] (
    [adID]      INT             IDENTITY (1, 1) NOT NULL,
    [Tm]        CHAR (8)        NULL,
    [TrackType] VARCHAR (30)    NULL,
    [tmStart]   CHAR (8)        NULL,
    [tmEnd]     CHAR (8)        NULL,
    [PosX]      DECIMAL (10, 6) NOT NULL,
    [PosY]      DECIMAL (10, 6) NULL,
    [F1]        DECIMAL (10, 2) NULL,
    [F2]        DECIMAL (10, 2) NULL,
    [F3]        DECIMAL (10, 2) NULL,
    [F4]        DECIMAL (10, 2) NULL,
    [atID]      INT             NULL,
    [Pin]       INT             NULL,
    CONSTRAINT [PK__AgentTra__6CFBF34091C0A8F5] PRIMARY KEY CLUSTERED ([adID] ASC),
    CONSTRAINT [AgentTrackDet_fk] FOREIGN KEY ([atID]) REFERENCES [MobAgents].[AgentTrack] ([atID]) ON UPDATE CASCADE
);

