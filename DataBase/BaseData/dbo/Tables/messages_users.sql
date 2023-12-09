CREATE TABLE [dbo].[messages_users] (
    [id]         INT          IDENTITY (1, 1) NOT NULL,
    [ip_address] VARCHAR (15) NULL,
    [user_name]  VARCHAR (32) NULL,
    [active]     BIT          DEFAULT ((0)) NULL,
    [nd]         DATETIME     NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'пользователи системы уведомлений', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'messages_users';

