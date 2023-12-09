CREATE TABLE [dbo].[CKLog] (
    [CKLogID]   INT            IDENTITY (1, 1) NOT NULL,
    [NoOper]    INT            NULL,
    [ND]        DATETIME       NULL,
    [TM]        CHAR (8)       NULL,
    [B_ID]      INT            NULL,
    [Plata]     MONEY          NULL,
    [Nds0]      MONEY          NULL,
    [Nds10]     MONEY          NULL,
    [Nds18]     MONEY          NULL,
    [Op]        INT            NULL,
    [remark]    VARCHAR (50)   NULL,
    [Our_ID]    SMALLINT       NULL,
    [datnom]    INT            NULL,
    [KassID]    INT            NULL,
    [CkId]      INT            NOT NULL,
    [type]      SMALLINT       NULL,
    [user_name] NVARCHAR (256) CONSTRAINT [DF__CKLog__user_name__46BFCEDF] DEFAULT (suser_sname()) NULL,
    [datetime]  DATETIME       CONSTRAINT [DF__CKLog__datetime__47B3F318] DEFAULT (getdate()) NULL,
    [host_name] NCHAR (30)     CONSTRAINT [DF__CKLog__host_name__48A81751] DEFAULT (host_name()) NULL,
    [app_name]  NVARCHAR (128) CONSTRAINT [DF__CKLog__app_name__499C3B8A] DEFAULT (app_name()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя приложения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CKLog', @level2type = N'COLUMN', @level2name = N'app_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя компа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CKLog', @level2type = N'COLUMN', @level2name = N'host_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CKLog', @level2type = N'COLUMN', @level2name = N'datetime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя пользователя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CKLog', @level2type = N'COLUMN', @level2name = N'user_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип изменения 0 - insert, 1 - delete, 2 - update', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CKLog', @level2type = N'COLUMN', @level2name = N'type';

