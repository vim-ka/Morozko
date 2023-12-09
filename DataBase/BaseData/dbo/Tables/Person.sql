CREATE TABLE [dbo].[Person] (
    [P_ID]        INT           IDENTITY (1, 1) NOT NULL,
    [Fio]         VARCHAR (100) NULL,
    [trID]        INT           NULL,
    [Invis]       BIT           CONSTRAINT [DF__Person__Invis__1923ECB8] DEFAULT ((0)) NULL,
    [V_ID]        INT           NULL,
    [Our_ID]      SMALLINT      CONSTRAINT [DF__Person__Our_ID__1A1810F1] DEFAULT ((6)) NULL,
    [DepID]       INT           CONSTRAINT [DF__Person__DepID__1B0C352A] DEFAULT ((0)) NOT NULL,
    [Closed]      BIT           CONSTRAINT [DF__Person__Closed__1C005963] DEFAULT ((0)) NULL,
    [ag_id]       INT           NULL,
    [sv_id]       INT           NULL,
    [uin]         INT           NULL,
    [DepDirector] BIT           CONSTRAINT [DF__Person__DepDirec__1CF47D9C] DEFAULT ((0)) NULL,
    [Phone]       CHAR (50)     NULL,
    [Email]       VARCHAR (70)  NULL,
    [login]       VARCHAR (32)  NULL,
    [pwd]         VARCHAR (32)  NULL,
    [NDBeg]       DATETIME      CONSTRAINT [DF__Person__NDBeg__1DE8A1D5] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [NDEnd]       DATETIME      NULL,
    [OP]          INT           NULL,
    [Agent]       BIT           CONSTRAINT [DF__Person__Agent__1EDCC60E] DEFAULT ((0)) NULL,
    [Supervis]    BIT           CONSTRAINT [DF__Person__Supervis__1FD0EA47] DEFAULT ((0)) NULL,
    [svP_ID]      INT           CONSTRAINT [DF__Person__svP_ID__20C50E80] DEFAULT ((0)) NULL,
    [Remark]      VARCHAR (100) NULL,
    [PersID]      INT           NULL,
    [HRPersID]    INT           NOT NULL,
    [dubl]        BIT           NULL,
    CONSTRAINT [Person_pk] PRIMARY KEY CLUSTERED ([P_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Person_idx]
    ON [dbo].[Person]([ag_id] ASC);


GO


CREATE TRIGGER [dbo].[trg_Person_u] ON [dbo].[Person]
WITH EXECUTE AS CALLER
FOR UPDATE
AS
      begin
          insert into PersonLog (P_ID, Fio, trID, Invis, V_ID, Our_ID, DepID, Closed, ag_id, sv_id, uin, DepDirector, Phone, Email, login, pwd, NDBeg, NDEnd, OP, Agent, Supervis, svP_ID, Remark, PersID, HRPersID, [type], user_app_name)
          select P_ID, Fio, trID, Invis, V_ID, Our_ID, DepID, Closed, ag_id, sv_id, uin, DepDirector, Phone, Email, login, pwd, NDBeg, NDEnd, OP, Agent, Supervis, svP_ID, Remark, PersID, HRPersID, 2, APP_NAME() from deleted
      end
GO


CREATE TRIGGER [dbo].[trg_Person_d] ON [dbo].[Person]
WITH EXECUTE AS CALLER
FOR DELETE
AS
      begin
          insert into PersonLog (P_ID, Fio, trID, Invis, V_ID, Our_ID, DepID, Closed, ag_id, sv_id, uin, DepDirector, Phone, Email, login, pwd, NDBeg, NDEnd, OP, Agent, Supervis, svP_ID, Remark, PersID, HRPersID, [type], user_app_name)
          select P_ID, Fio, trID, Invis, V_ID, Our_ID, DepID, Closed, ag_id, sv_id, uin, DepDirector, Phone, Email, login, pwd, NDBeg, NDEnd, OP, Agent, Supervis, svP_ID, Remark, PersID, HRPersID, 1, APP_NAME() from deleted
      end
GO


CREATE TRIGGER [dbo].[trg_Person_i] ON [dbo].[Person]
WITH EXECUTE AS CALLER
FOR INSERT
AS
      begin
          insert into PersonLog (P_ID, Fio, trID, Invis, V_ID, Our_ID, DepID, Closed, ag_id, sv_id, uin, DepDirector, Phone, Email, login, pwd, NDBeg, NDEnd, OP, Agent, Supervis, svP_ID, Remark, PersID, HRPersID, [type], user_app_name)
          select P_ID, Fio, trID, Invis, V_ID, Our_ID, DepID, Closed, ag_id, sv_id, uin, DepDirector, Phone, Email, login, pwd, NDBeg, NDEnd, OP, Agent, Supervis, svP_ID, Remark, PersID, HRPersID, 0, APP_NAME()  from inserted
      end
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дубликат', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'dubl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'синхронизация: ID персоны в новом HR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'HRPersID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'синхронизация с HR PersonData', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'PersID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код супервайзера (для агентов) к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'svP_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Является супервайзером к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'Supervis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Является агентом к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'Agent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Заводивший оператор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата закрытия', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'NDEnd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата заведения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'NDBeg';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Пароль к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'pwd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Логин к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'login';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'E-mail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'Email';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Телефон', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Начальник отдела', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'DepDirector';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'uin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'sv_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'ag_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Закрыт', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'Closed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отдел', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Организация', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'Our_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Скрытый', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'Invis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Должность', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'trID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ФИО', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Person', @level2type = N'COLUMN', @level2name = N'Fio';

