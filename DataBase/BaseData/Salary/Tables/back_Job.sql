CREATE TABLE [Salary].[back_Job] (
    [sjID]      INT            IDENTITY (1, 1) NOT NULL,
    [Day0]      DATE           NULL,
    [Day1]      DATE           NULL,
    [Active]    BIT            NULL,
    [tipWho]    CHAR (1)       NULL,
    [codeWho]   INT            NULL,
    [tipWhat]   CHAR (1)       NULL,
    [tipPlan]   CHAR (1)       NULL,
    [Plan]      INT            NULL,
    [BonusPerc] DECIMAL (6, 2) NULL
);

