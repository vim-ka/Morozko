CREATE TABLE [VanSell].[taskpoint] (
    [tpid]   INT           IDENTITY (1, 1) NOT NULL,
    [pin]    INT           NULL,
    [gpname] VARCHAR (100) NULL,
    [gpaddr] VARCHAR (100) NULL,
    [taskid] INT           NULL,
    [org]    INT           DEFAULT ((7)) NULL,
    UNIQUE NONCLUSTERED ([tpid] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [taskpoint_uq]
    ON [VanSell].[taskpoint]([pin] ASC, [taskid] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Контрагенты (торговые точки), taskid - ссылка на таблицу заданий (task)', @level0type = N'SCHEMA', @level0name = N'VanSell', @level1type = N'TABLE', @level1name = N'taskpoint';

