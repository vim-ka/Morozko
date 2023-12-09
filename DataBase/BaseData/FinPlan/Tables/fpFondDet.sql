CREATE TABLE [FinPlan].[fpFondDet] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [fond_id]   INT             NULL,
    [period_id] INT             NULL,
    [ost_beg]   NUMERIC (16, 2) DEFAULT ((0)) NULL,
    [ost_end]   NUMERIC (16, 2) DEFAULT ((0)) NULL,
    [kso]       INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

