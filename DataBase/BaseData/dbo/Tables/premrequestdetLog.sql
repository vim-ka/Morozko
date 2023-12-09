CREATE TABLE [dbo].[premrequestdetLog] (
    [prid]      INT             NULL,
    [p_id]      INT             NULL,
    [main_proc] NUMERIC (5, 2)  NULL,
    [main_sum]  NUMERIC (18, 2) NULL,
    [linkdet]   INT             NULL,
    [comm]      VARCHAR (512)   NULL,
    [vednum]    INT             NULL,
    [LogID]     INT             IDENTITY (1, 1) NOT NULL,
    [ID]        INT             NOT NULL,
    [type]      SMALLINT        NULL,
    [user_name] NVARCHAR (256)  DEFAULT (suser_sname()) NULL,
    [datetime]  DATETIME        DEFAULT (getdate()) NULL,
    [host_name] NCHAR (30)      DEFAULT (host_name()) NULL,
    [app_name]  NVARCHAR (128)  DEFAULT (app_name()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя приложения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'premrequestdetLog', @level2type = N'COLUMN', @level2name = N'app_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя компа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'premrequestdetLog', @level2type = N'COLUMN', @level2name = N'host_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'premrequestdetLog', @level2type = N'COLUMN', @level2name = N'datetime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя пользователя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'premrequestdetLog', @level2type = N'COLUMN', @level2name = N'user_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип изменения 0 - insert, 1 - delete, 2 - update', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'premrequestdetLog', @level2type = N'COLUMN', @level2name = N'type';

