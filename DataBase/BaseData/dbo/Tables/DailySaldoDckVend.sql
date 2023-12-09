CREATE TABLE [dbo].[DailySaldoDckVend] (
    [ND]            DATETIME NULL,
    [pin]           INT      NULL,
    [DCK]           INT      NULL,
    [Cred]          MONEY    NULL,
    [OverdueCredit] MONEY    NULL,
    [DeepCredit]    INT      NULL,
    CONSTRAINT [DailySaldoDckVend_uq_copy] UNIQUE NONCLUSTERED ([pin] ASC, [DCK] ASC, [ND] ASC)
);

