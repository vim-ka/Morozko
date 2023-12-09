CREATE TABLE [FinPlan].[FondParts] (
    [fpID]  INT      IDENTITY (1, 1) NOT NULL,
    [NmID]  INT      NULL,
    [Hitag] INT      NULL,
    [p_id]  INT      NULL,
    [Delta] SMALLINT NULL,
    [FgID]  INT      NULL,
    PRIMARY KEY CLUSTERED ([fpID] ASC)
);

