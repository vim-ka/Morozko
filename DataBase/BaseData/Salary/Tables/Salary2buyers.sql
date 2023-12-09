CREATE TABLE [Salary].[Salary2buyers] (
    [s2id]     INT             NULL,
    [b_id]     INT             NULL,
    [dck]      INT             NULL,
    [ag_id]    INT             NULL,
    [Debt]     DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Overdue]  DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Plata]    DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [OverUp17] DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Sell]     DECIMAL (12, 2) DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [Salary2buyers_s2idx]
    ON [Salary].[Salary2buyers]([s2id] ASC);


GO
CREATE CLUSTERED INDEX [Salary2buyers_BidDck_idx]
    ON [Salary].[Salary2buyers]([b_id] ASC, [dck] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Просрочка 17 и более дней', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2buyers', @level2type = N'COLUMN', @level2name = N'OverUp17';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Выплаты покупателей за период', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2buyers', @level2type = N'COLUMN', @level2name = N'Plata';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Просрочка на конец периода', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2buyers', @level2type = N'COLUMN', @level2name = N'Overdue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дебиторская задолженность на конец периода', @level0type = N'SCHEMA', @level0name = N'Salary', @level1type = N'TABLE', @level1name = N'Salary2buyers', @level2type = N'COLUMN', @level2name = N'Debt';

