CREATE TABLE [dbo].[NCEditLog] (
    [ND]          DATETIME       NULL,
    [TM]          CHAR (8)       NULL,
    [Nnak]        INT            NULL,
    [DatNom]      BIGINT         NULL,
    [B_ID]        INT            NULL,
    [BrName]      VARCHAR (100)  NULL,
    [OP]          SMALLINT       NULL,
    [SP]          MONEY          NULL,
    [SC]          MONEY          NULL,
    [NewSP]       MONEY          NULL,
    [NewSC]       MONEY          NULL,
    [Mode]        INT            NULL,
    [Extra]       NUMERIC (6, 2) NULL,
    [Srok]        SMALLINT       NULL,
    [NalogEXST]   BIT            NULL,
    [Nalog]       MONEY          NULL,
    [Our_ID]      TINYINT        NULL,
    [DCK]         INT            NULL,
    [NewDCK]      INT            NULL,
    [NewExtra]    NUMERIC (6, 2) NULL,
    [NCEditLogID] INT            IDENTITY (1, 1) NOT NULL,
    [NCID]        INT            NOT NULL,
    [type]        SMALLINT       NULL,
    [user_name]   NVARCHAR (256) DEFAULT (suser_sname()) NULL,
    [datetime]    DATETIME       DEFAULT (getdate()) NULL,
    [host_name]   NCHAR (30)     DEFAULT (host_name()) NULL,
    [app_name]    NVARCHAR (128) DEFAULT (app_name()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя приложения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCEditLog', @level2type = N'COLUMN', @level2name = N'app_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя компа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCEditLog', @level2type = N'COLUMN', @level2name = N'host_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCEditLog', @level2type = N'COLUMN', @level2name = N'datetime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя пользователя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCEditLog', @level2type = N'COLUMN', @level2name = N'user_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип изменения 0 - insert, 1 - delete, 2 - update', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NCEditLog', @level2type = N'COLUMN', @level2name = N'type';

