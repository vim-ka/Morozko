CREATE TABLE [dbo].[PsScoresHist] (
    [ND]       DATETIME NULL,
    [P_ID]     INT      NOT NULL,
    [StID]     INT      DEFAULT ((0)) NOT NULL,
    [StNom]    AS       ([P_ID]*(100)+[StID]) PERSISTED,
    [Must]     MONEY    DEFAULT ((0)) NULL,
    [OverMust] MONEY    NULL
);

