CREATE TABLE [dbo].[FrizerStick] (
    [fsID]       SMALLINT     IDENTITY (1, 1) NOT NULL,
    [StickName]  VARCHAR (50) NULL,
    [ShortStick] VARCHAR (5)  NULL,
    CONSTRAINT [FrizerStik_pk] PRIMARY KEY CLUSTERED ([fsID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'краткое обозначение', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerStick', @level2type = N'COLUMN', @level2name = N'ShortStick';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Полное наименование стикера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerStick', @level2type = N'COLUMN', @level2name = N'StickName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Таблица стикеров для ХО', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerStick';

