CREATE TABLE [RetroB].[BasRules] (
    [RuleID]  INT             IDENTITY (1, 1) NOT NULL,
    [FondID]  INT             NOT NULL,
    [Day0]    DATETIME        NULL,
    [Day1]    DATETIME        NULL,
    [Perc]    DECIMAL (6, 2)  NULL,
    [AddCost] DECIMAL (10, 2) NULL,
    [Active]  BIT             DEFAULT ((1)) NULL,
    [Name]    VARCHAR (100)   NULL,
    [Remark]  VARCHAR (40)    NULL,
    [tip]     INT             DEFAULT ((-1)) NULL,
    [BPMid]   INT             NULL,
    PRIMARY KEY CLUSTERED ([RuleID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Добавка в рублях к цене прихода', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'BasRules', @level2type = N'COLUMN', @level2name = N'AddCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Добавка в процентах к цене прихода', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'BasRules', @level2type = N'COLUMN', @level2name = N'Perc';

