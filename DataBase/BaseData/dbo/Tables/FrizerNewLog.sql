CREATE TABLE [dbo].[FrizerNewLog] (
    [Tip]            SMALLINT        NULL,
    [Mode]           CHAR (1)        NULL,
    [InvNom]         VARCHAR (20)    NULL,
    [FabNom]         VARCHAR (15)    NULL,
    [Nname]          VARCHAR (60)    NULL,
    [Ncod]           INT             NULL,
    [DatePost]       DATETIME        NULL,
    [OurId]          TINYINT         NULL,
    [Ob]             FLOAT (53)      NULL,
    [Korzin]         SMALLINT        NULL,
    [Zamok]          TINYINT         NULL,
    [Sticker]        VARCHAR (3)     NULL,
    [B_ID]           INT             NOT NULL,
    [DateSell]       DATETIME        NULL,
    [Remark]         VARCHAR (20)    NULL,
    [DogNom]         VARCHAR (20)    NULL,
    [Price]          MONEY           NULL,
    [DateCheck]      DATETIME        NULL,
    [DateCheckAgent] DATETIME        NULL,
    [NCom]           INT             NULL,
    [SkladNo]        SMALLINT        NULL,
    [Procreator]     VARCHAR (20)    NULL,
    [NCountry]       INT             NULL,
    [Cost]           DECIMAL (13, 5) NULL,
    [fsID]           SMALLINT        NOT NULL,
    [mID]            SMALLINT        NULL,
    [CondID]         INT             NULL,
    [hitag]          INT             NULL,
    [B_ID1]          INT             NULL,
    [StartPrice]     MONEY           NOT NULL,
    [DateStart]      DATETIME        NULL,
    [DateAct]        DATETIME        NULL,
    [InmarkoTip]     INT             NULL,
    [InvNom2]        VARCHAR (30)    NULL,
    [ffid]           INT             NULL,
    [DCK]            INT             NULL,
    [LogID]          INT             IDENTITY (1, 1) NOT NULL,
    [Nom]            INT             NOT NULL,
    [type]           SMALLINT        NULL,
    [user_name]      NVARCHAR (256)  DEFAULT (suser_sname()) NULL,
    [datetime]       DATETIME        DEFAULT (getdate()) NULL,
    [host_name]      NCHAR (30)      DEFAULT (host_name()) NULL,
    [app_name]       NVARCHAR (128)  DEFAULT (app_name()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя приложения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerNewLog', @level2type = N'COLUMN', @level2name = N'app_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя компа', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerNewLog', @level2type = N'COLUMN', @level2name = N'host_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'время изменения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerNewLog', @level2type = N'COLUMN', @level2name = N'datetime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'имя пользователя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerNewLog', @level2type = N'COLUMN', @level2name = N'user_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип изменения 0 - insert, 1 - delete, 2 - update', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FrizerNewLog', @level2type = N'COLUMN', @level2name = N'type';

