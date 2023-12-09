CREATE TABLE [FinPlan].[fpRS] (
    [id]       INT             IDENTITY (1, 1) NOT NULL,
    [rs_code]  INT             NULL,
    [nd]       DATETIME        NULL,
    [plat_sum] NUMERIC (12, 2) NULL,
    [our_id]   INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

