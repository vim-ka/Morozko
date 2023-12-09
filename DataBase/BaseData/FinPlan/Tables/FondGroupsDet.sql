CREATE TABLE [FinPlan].[FondGroupsDet] (
    [fgdID] INT IDENTITY (1, 1) NOT NULL,
    [FgID]  INT NOT NULL,
    [P_ID]  INT NULL,
    PRIMARY KEY CLUSTERED ([fgdID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [FondGroupsDet_uq]
    ON [FinPlan].[FondGroupsDet]([FgID] ASC, [P_ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер фонда (подотчетного лица в табл. Person, или -1)', @level0type = N'SCHEMA', @level0name = N'FinPlan', @level1type = N'TABLE', @level1name = N'FondGroupsDet', @level2type = N'COLUMN', @level2name = N'P_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ссылка на ключ в табл. finplan.FondGroups', @level0type = N'SCHEMA', @level0name = N'FinPlan', @level1type = N'TABLE', @level1name = N'FondGroupsDet', @level2type = N'COLUMN', @level2name = N'FgID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ключ', @level0type = N'SCHEMA', @level0name = N'FinPlan', @level1type = N'TABLE', @level1name = N'FondGroupsDet', @level2type = N'COLUMN', @level2name = N'fgdID';

