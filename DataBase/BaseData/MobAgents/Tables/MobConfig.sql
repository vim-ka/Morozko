CREATE TABLE [MobAgents].[MobConfig] (
    [param]   VARCHAR (30) NULL,
    [val]     VARCHAR (30) NULL,
    [comment] VARCHAR (50) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Комментарий', @level0type = N'SCHEMA', @level0name = N'MobAgents', @level1type = N'TABLE', @level1name = N'MobConfig', @level2type = N'COLUMN', @level2name = N'comment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Значение параметра', @level0type = N'SCHEMA', @level0name = N'MobAgents', @level1type = N'TABLE', @level1name = N'MobConfig', @level2type = N'COLUMN', @level2name = N'val';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Наименование параметра', @level0type = N'SCHEMA', @level0name = N'MobAgents', @level1type = N'TABLE', @level1name = N'MobConfig', @level2type = N'COLUMN', @level2name = N'param';

