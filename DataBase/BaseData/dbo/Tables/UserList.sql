CREATE TABLE [dbo].[UserList] (
    [id]    INT IDENTITY (1, 1) NOT NULL,
    [p_id]  INT NULL,
    [grpid] INT NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пользователи в группах - редактировать ОЧЕНЬ аккуратно', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserList';

