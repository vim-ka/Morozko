CREATE TABLE [dbo].[Permissions] (
    [pID]        INT          NULL,
    [Prg]        TINYINT      NULL,
    [PermisName] VARCHAR (50) NULL,
    [ParentPID]  INT          NULL,
    CONSTRAINT [Permissions_uq] UNIQUE CLUSTERED ([pID] ASC, [Prg] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фио пользователя (или наименование разрешения)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Permissions', @level2type = N'COLUMN', @level2name = N'PermisName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип программы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Permissions', @level2type = N'COLUMN', @level2name = N'Prg';

