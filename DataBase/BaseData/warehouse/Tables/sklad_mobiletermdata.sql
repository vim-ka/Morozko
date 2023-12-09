CREATE TABLE [warehouse].[sklad_mobiletermdata] (
    [id]       INT          IDENTITY (1, 1) NOT NULL,
    [tip]      INT          DEFAULT ((1)) NULL,
    [mhid]     INT          NULL,
    [datnom]   INT          NULL,
    [hitag]    INT          NULL,
    [kol]      INT          NULL,
    [spk]      INT          NULL,
    [dt]       DATETIME     DEFAULT (getdate()) NULL,
    [compname] VARCHAR (64) NULL,
    [locked]   BIT          DEFAULT ((0)) NULL,
    [op]       INT          DEFAULT ((-1)) NOT NULL,
    [groupid]  INT          DEFAULT ((-1)) NOT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'заблокировано от изменений', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_mobiletermdata', @level2type = N'COLUMN', @level2name = N'locked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя терминала', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_mobiletermdata', @level2type = N'COLUMN', @level2name = N'compname';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата сканирования', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_mobiletermdata', @level2type = N'COLUMN', @level2name = N'dt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код сотрудника склада', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_mobiletermdata', @level2type = N'COLUMN', @level2name = N'spk';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'кол-во', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_mobiletermdata', @level2type = N'COLUMN', @level2name = N'kol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код товара', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_mobiletermdata', @level2type = N'COLUMN', @level2name = N'hitag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код накладной', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_mobiletermdata', @level2type = N'COLUMN', @level2name = N'datnom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код маршрута', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_mobiletermdata', @level2type = N'COLUMN', @level2name = N'mhid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип сканирования: 1 - проверка сканером 2 - ручной ввод', @level0type = N'SCHEMA', @level0name = N'warehouse', @level1type = N'TABLE', @level1name = N'sklad_mobiletermdata', @level2type = N'COLUMN', @level2name = N'tip';

