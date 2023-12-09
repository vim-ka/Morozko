CREATE TABLE [VanSell].[task] (
    [taskid] INT          IDENTITY (1, 1) NOT NULL,
    [p_id]   INT          NULL,
    [fio]    VARCHAR (64) NULL,
    [nd]     DATETIME     NULL,
    [status] INT          DEFAULT ((1)) NULL,
    [Remark] VARCHAR (50) NULL,
    UNIQUE NONCLUSTERED ([taskid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Задание - кто едет, status - 1 - создано, 2 - принято к исп., 3 - исполнено, 4- отменено', @level0type = N'SCHEMA', @level0name = N'VanSell', @level1type = N'TABLE', @level1name = N'task';

