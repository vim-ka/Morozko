CREATE TABLE [Salary].[Salary2buyersDebug] (
    [s2id]     INT             NULL,
    [b_id]     INT             NULL,
    [dck]      INT             NULL,
    [ag_id]    INT             NULL,
    [Debt]     DECIMAL (12, 2) NULL,
    [Overdue]  DECIMAL (12, 2) NULL,
    [Plata]    DECIMAL (12, 2) NULL,
    [OverUp17] DECIMAL (12, 2) NULL,
    [Sell]     DECIMAL (12, 2) NULL
);


GO
CREATE NONCLUSTERED INDEX [s2bs2id]
    ON [Salary].[Salary2buyersDebug]([s2id] ASC);


GO
CREATE NONCLUSTERED INDEX [s2bdBDCK]
    ON [Salary].[Salary2buyersDebug]([b_id] ASC, [dck] ASC);

