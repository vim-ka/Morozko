CREATE TABLE [Guard].[Chain] (
    [chId]       INT      IDENTITY (1, 1) NOT NULL,
    [nd]         DATETIME DEFAULT ([dbo].[today]()) NULL,
    [SourAG_ID]  INT      NULL,
    [ChainAg_Id] INT      NULL,
    [Day0]       DATETIME NULL,
    [Day1]       DATETIME NULL,
    [Op]         INT      NULL,
    [WholeAgent] BIT      DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([chId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-все ТТ агента,0-только ТТ из списка Guard.ChainDet', @level0type = N'SCHEMA', @level0name = N'Guard', @level1type = N'TABLE', @level1name = N'Chain', @level2type = N'COLUMN', @level2name = N'WholeAgent';

