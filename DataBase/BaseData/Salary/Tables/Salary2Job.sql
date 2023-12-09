CREATE TABLE [Salary].[Salary2Job] (
    [sjID]      INT            IDENTITY (1, 1) NOT NULL,
    [Day0]      DATE           NULL,
    [Day1]      DATE           NULL,
    [Active]    BIT            DEFAULT ((1)) NULL,
    [tipWho]    CHAR (1)       CONSTRAINT [DF__Salary2Jo__tipWh__434443B6] DEFAULT ('D') NULL,
    [codeWho]   INT            NULL,
    [tipWhat]   CHAR (1)       DEFAULT ('S') NULL,
    [tipPlan]   CHAR (1)       DEFAULT ('R') NULL,
    [Plan]      INT            NULL,
    [BonusPerc] DECIMAL (6, 2) NULL,
    PRIMARY KEY CLUSTERED ([sjID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'[R]убли, [K]оличество клиентов', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Job', @level2type = N'COLUMN', @level2name = N'tipPlan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Признак [S]упергруппа, [G]руппа, [P]роизводитель, [H]itag. Сами значения в salary.Salary2jobWhat.CodeWhat', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Job', @level2type = N'COLUMN', @level2name = N'tipWhat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'[D]епартамент, [S]упервайзер, [A]гент', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2Job', @level2type = N'COLUMN', @level2name = N'tipWho';

