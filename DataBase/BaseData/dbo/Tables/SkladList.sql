CREATE TABLE [dbo].[SkladList] (
    [SkladNo]       INT          NOT NULL,
    [SkladName]     VARCHAR (50) NULL,
    [skg]           SMALLINT     NOT NULL,
    [Must]          MONEY        NULL,
    [OnlyMinP]      BIT          CONSTRAINT [DF__SkladList__OnlyM__3B36AB95] DEFAULT ((0)) NOT NULL,
    [Locked]        BIT          CONSTRAINT [DF__SkladList__Disab__37861642] DEFAULT ((0)) NOT NULL,
    [AgInvis]       BIT          CONSTRAINT [DF__SkladList__AgInv__387A3A7B] DEFAULT ((0)) NOT NULL,
    [DisMinExtra]   BIT          CONSTRAINT [DF__SkladList__DisMi__2D9D84AC] DEFAULT ((0)) NOT NULL,
    [Discard]       BIT          CONSTRAINT [DF__SkladList__Disca__2EBC916E] DEFAULT ((0)) NULL,
    [SafeCust]      BIT          CONSTRAINT [DF__SkladList__SafeC__2C2B08DD] DEFAULT ((0)) NULL,
    [Equipment]     BIT          CONSTRAINT [DF__SkladList__Equip__02F4B477] DEFAULT ((0)) NULL,
    [UpWeight]      BIT          CONSTRAINT [DF__SkladList__UpWei__55ADD80B] DEFAULT ((0)) NULL,
    [SkladOperLock] BIT          DEFAULT ((0)) NOT NULL,
    [Discount]      BIT          DEFAULT ((0)) NOT NULL,
    [srid]          INT          DEFAULT ((0)) NOT NULL,
    [isGroup]       BIT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([SkladNo] ASC)
);


GO
CREATE NONCLUSTERED INDEX [SkladList_idx]
    ON [dbo].[SkladList]([SkladNo] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Склад уценки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'Discount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Блокировка всех складских операций', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'SkladOperLock';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-в NvZakaz', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'UpWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Возможно размещение оборудования', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'Equipment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ответ Хранение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'SafeCust';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Склад "Брак"', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'Discard';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Минимальная наценка выключена', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'DisMinExtra';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Скрытые от торговых агентов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'AgInvis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Продажа запрещена (только просмотр)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'Locked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отгрузка только коробками', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'OnlyMinP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'группа в табл Skladlist', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'skg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'наименование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SkladList', @level2type = N'COLUMN', @level2name = N'SkladName';

