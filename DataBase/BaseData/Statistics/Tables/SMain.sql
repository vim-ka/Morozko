CREATE TABLE [Statistics].[SMain] (
    [id]     INT IDENTITY (1, 1) NOT NULL,
    [p_id]   INT NULL,
    [statid] INT NULL,
    [depid]  INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'основная таблица статистик по сотрудникам', @level0type = N'SCHEMA', @level0name = N'Statistics', @level1type = N'TABLE', @level1name = N'SMain';

