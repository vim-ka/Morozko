CREATE TABLE [dbo].[PsScores] (
    [P_ID]      INT          NOT NULL,
    [StID]      INT          CONSTRAINT [DF__PsScores__stNom__33758E3C] DEFAULT ((0)) NOT NULL,
    [StNom]     AS           ([P_ID]*(100)+[StID]) PERSISTED,
    [FName]     VARCHAR (30) NULL,
    [Must]      MONEY        DEFAULT ((0)) NULL,
    [BegDate]   DATETIME     NULL,
    [EndDate]   DATETIME     NULL,
    [OverMust]  MONEY        NULL,
    [OverDay]   INT          NULL,
    [DaysDelay] INT          DEFAULT ((0)) NULL,
    [nso]       BIT          DEFAULT ((0)) NULL,
    CONSTRAINT [PsScores_uq] UNIQUE CLUSTERED ([P_ID] ASC, [StID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [PsScores_idx2]
    ON [dbo].[PsScores]([DaysDelay] ASC);


GO
CREATE NONCLUSTERED INDEX [PsScores_idx]
    ON [dbo].[PsScores]([StNom] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Неснижаемый остаток, проводка операции в долг на данном контрагенте запрещена', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PsScores', @level2type = N'COLUMN', @level2name = N'nso';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дней до просрочки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PsScores', @level2type = N'COLUMN', @level2name = N'DaysDelay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Просрочено в днях', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PsScores', @level2type = N'COLUMN', @level2name = N'OverDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Просрочено', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PsScores', @level2type = N'COLUMN', @level2name = N'OverMust';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата закрытия статьи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PsScores', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата открытия статьи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PsScores', @level2type = N'COLUMN', @level2name = N'BegDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Долг по статье', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PsScores', @level2type = N'COLUMN', @level2name = N'Must';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Упакованный номер подотчетного и статьи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PsScores', @level2type = N'COLUMN', @level2name = N'StNom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код статьи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PsScores', @level2type = N'COLUMN', @level2name = N'StID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код подотчетного', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PsScores', @level2type = N'COLUMN', @level2name = N'P_ID';

