CREATE TABLE [dbo].[MarshSkMan] (
    [mskId]        INT      IDENTITY (1, 1) NOT NULL,
    [mhid]         INT      DEFAULT ((0)) NOT NULL,
    [spk]          INT      NOT NULL,
    [WorkerID]     INT      DEFAULT ((0)) NULL,
    [TrId]         INT      DEFAULT ((0)) NULL,
    [skg]          INT      DEFAULT ((0)) NULL,
    [uin]          INT      DEFAULT ((0)) NULL,
    [ND]           DATETIME DEFAULT (CONVERT([varchar],getdate(),(104))) NULL,
    [TM]           CHAR (8) DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [Checking]     BIT      DEFAULT ((0)) NULL,
    [TimeChecking] DATETIME NULL,
    PRIMARY KEY CLUSTERED ([mskId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [MarshSkMan_idx]
    ON [dbo].[MarshSkMan]([mhid] ASC);


GO
CREATE NONCLUSTERED INDEX [MarshSkMan_idx2]
    ON [dbo].[MarshSkMan]([spk] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время установки флага Checking', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSkMan', @level2type = N'COLUMN', @level2name = N'TimeChecking';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Проверен ли реестр набора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSkMan', @level2type = N'COLUMN', @level2name = N'Checking';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код из таблицы usrPwd', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSkMan', @level2type = N'COLUMN', @level2name = N'uin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'складская группа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSkMan', @level2type = N'COLUMN', @level2name = N'skg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ключ из таблицы Trades (должность)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSkMan', @level2type = N'COLUMN', @level2name = N'TrId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1-кладовщик
2-наборщик
3-грузчик', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSkMan', @level2type = N'COLUMN', @level2name = N'WorkerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код складского работника из SkladPerson', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSkMan', @level2type = N'COLUMN', @level2name = N'spk';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id маршрута', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSkMan', @level2type = N'COLUMN', @level2name = N'mhid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица складских работников набирающих маршрут из табл Marsh', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshSkMan';

