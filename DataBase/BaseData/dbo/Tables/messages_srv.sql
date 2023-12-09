CREATE TABLE [dbo].[messages_srv] (
    [ip] VARCHAR (255) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ip адрес сервера уведомлений', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'messages_srv';

