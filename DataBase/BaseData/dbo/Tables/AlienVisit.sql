CREATE TABLE [dbo].[AlienVisit] (
    [avID] INT         IDENTITY (1, 1) NOT NULL,
    [Pin]  INT         NULL,
    [AlID] INT         NULL,
    [Dow]  TINYINT     NULL,
    [Tm]   VARCHAR (8) NULL,
    PRIMARY KEY CLUSTERED ([avID] ASC)
);

