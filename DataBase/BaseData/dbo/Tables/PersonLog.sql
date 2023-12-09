CREATE TABLE [dbo].[PersonLog] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [P_ID]          INT           NULL,
    [Fio]           VARCHAR (100) NULL,
    [trID]          INT           NULL,
    [Invis]         BIT           CONSTRAINT [DF__PersonLog__Invis__3D6081D7] DEFAULT ((0)) NULL,
    [V_ID]          INT           NULL,
    [Our_ID]        SMALLINT      CONSTRAINT [DF__PersonLog__Our_ID__3E54A610] DEFAULT ((7)) NULL,
    [DepID]         INT           CONSTRAINT [DF__PersonLog__DepID__3F48CA49] DEFAULT ((0)) NULL,
    [Closed]        BIT           CONSTRAINT [DF__PersonLog__Closed__403CEE82] DEFAULT ((0)) NULL,
    [ag_id]         INT           NULL,
    [sv_id]         INT           NULL,
    [uin]           INT           NULL,
    [DepDirector]   BIT           CONSTRAINT [DF__PersonLog__DepDirec__413112BB] DEFAULT ((0)) NULL,
    [Phone]         CHAR (50)     NULL,
    [Email]         VARCHAR (70)  NULL,
    [login]         VARCHAR (20)  NULL,
    [pwd]           VARCHAR (32)  NULL,
    [NDBeg]         DATETIME      CONSTRAINT [DF__PersonLog__NDBeg__43195B2D] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [NDEnd]         DATETIME      NULL,
    [OP]            INT           NULL,
    [Agent]         BIT           CONSTRAINT [DF__PersonLog__Agent__440D7F66] DEFAULT ((0)) NULL,
    [Supervis]      BIT           CONSTRAINT [DF__PersonLog__Supervis__4501A39F] DEFAULT ((0)) NULL,
    [svP_ID]        INT           CONSTRAINT [DF__PersonLog__svP_ID__45F5C7D8] DEFAULT ((0)) NULL,
    [Remark]        VARCHAR (100) NULL,
    [PersID]        INT           NULL,
    [HRPersID]      INT           NULL,
    [user_id]       INT           NULL,
    [user_datetime] DATETIME      NULL,
    [user_type]     VARCHAR (3)   NULL,
    [user_app_name] VARCHAR (100) NULL,
    [host_name]     VARCHAR (64)  DEFAULT (host_name()) NULL,
    [type]          INT           NULL,
    [DT]            DATETIME      DEFAULT (getdate()) NULL,
    CONSTRAINT [PersonLog_uq] UNIQUE NONCLUSTERED ([id] ASC)
);


GO
CREATE CLUSTERED INDEX [PersonLog_idx]
    ON [dbo].[PersonLog]([DT] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'синхронизация: ID персоны в новом HR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'HRPersID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'синхронизация с HR PersonData', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'PersID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код супервайзера (для агентов) к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'svP_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Является супервайзером к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'Supervis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Является агентом к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'Agent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Заводивший оператор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата закрытия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'NDEnd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата заведения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'NDBeg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пароль к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'pwd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логин к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'login';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'E-mail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Начальник отдела', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'DepDirector';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'uin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'sv_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'ag_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Закрыт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'Closed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отдел', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Организация', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'Our_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Скрытый', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'Invis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Должность', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'trID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ФИО', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PersonLog', @level2type = N'COLUMN', @level2name = N'Fio';

