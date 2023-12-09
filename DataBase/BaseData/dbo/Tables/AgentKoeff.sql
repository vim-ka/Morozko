CREATE TABLE [dbo].[AgentKoeff] (
    [yymm]  INT             NULL,
    [ag_id] INT             NULL,
    [ncid]  INT             NULL,
    [koeff] DECIMAL (10, 5) CONSTRAINT [DF__AgentKoef__koeff__47C76B03] DEFAULT ((0)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Коэфф.для расчета без единицы.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentKoeff', @level2type = N'COLUMN', @level2name = N'koeff';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код группы товаров, 1..15', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentKoeff', @level2type = N'COLUMN', @level2name = N'ncid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код агента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentKoeff', @level2type = N'COLUMN', @level2name = N'ag_id';

