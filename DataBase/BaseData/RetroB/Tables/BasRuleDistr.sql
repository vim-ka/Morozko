CREATE TABLE [RetroB].[BasRuleDistr] (
    [id]     INT            IDENTITY (1, 1) NOT NULL,
    [ruleid] INT            NULL,
    [btid]   INT            NULL,
    [perc]   NUMERIC (5, 2) NULL,
    [bpmid]  INT            DEFAULT ((-1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'процент из части общих отчислений', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'BasRuleDistr', @level2type = N'COLUMN', @level2name = N'perc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ключ из BasTarget', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'BasRuleDistr', @level2type = N'COLUMN', @level2name = N'btid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'распределение', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'BasRuleDistr';

