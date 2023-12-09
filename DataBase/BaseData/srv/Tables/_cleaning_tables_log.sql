CREATE TABLE [srv].[_cleaning_tables_log] (
    [ctlID]    INT            IDENTITY (1, 1) NOT NULL,
    [nd]       NVARCHAR (10)  DEFAULT (CONVERT([nvarchar],getdate(),(104))) NOT NULL,
    [tm]       NVARCHAR (10)  DEFAULT (CONVERT([nvarchar],getdate(),(108))) NOT NULL,
    [comp]     NVARCHAR (50)  DEFAULT (host_name()) NOT NULL,
    [params]   NVARCHAR (500) NULL,
    [fetched]  INT            DEFAULT ((0)) NOT NULL,
    [commited] INT            DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ctlID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'обработано таблиц', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log', @level2type = N'COLUMN', @level2name = N'commited';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'найдено таблиц', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log', @level2type = N'COLUMN', @level2name = N'fetched';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'параметры запуска', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log', @level2type = N'COLUMN', @level2name = N'params';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'компьютер', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log', @level2type = N'COLUMN', @level2name = N'comp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log', @level2type = N'COLUMN', @level2name = N'tm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log', @level2type = N'COLUMN', @level2name = N'nd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'логирование запуска процедуры [srv].[_cleaning_tables]', @level0type = N'SCHEMA', @level0name = N'srv', @level1type = N'TABLE', @level1name = N'_cleaning_tables_log';

