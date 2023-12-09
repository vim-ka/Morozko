CREATE TABLE [dbo].[SertifPlan] (
    [WorkID]   INT           IDENTITY (1, 1) NOT NULL,
    [ND]       DATETIME      NULL,
    [sert_id]  INT           NULL,
    [endDate]  DATETIME      NULL,
    [isWasted] BIT           DEFAULT ((0)) NULL,
    [Comment]  VARCHAR (MAX) NULL,
    UNIQUE NONCLUSTERED ([WorkID] ASC)
);

