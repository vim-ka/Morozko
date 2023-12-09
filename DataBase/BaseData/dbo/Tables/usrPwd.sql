CREATE TABLE [dbo].[usrPwd] (
    [uin]               INT           NOT NULL,
    [fio]               VARCHAR (70)  NULL,
    [login]             VARCHAR (32)  NULL,
    [trID]              INT           NULL,
    [p_id]              INT           NULL,
    [DepID]             SMALLINT      NULL,
    [pwd]               VARCHAR (32)  DEFAULT ('202CB962AC59075B964B07152D234B70') NULL,
    [Email]             VARCHAR (50)  NULL,
    [NumScore]          VARCHAR (20)  NULL,
    [Rtr]               BIT           DEFAULT ((0)) NULL,
    [Extra]             BIT           DEFAULT ((0)) NULL,
    [PermisA2]          INT           DEFAULT ((0)) NULL,
    [PermisA4]          INT           DEFAULT ((0)) NULL,
    [PermisA5]          INT           DEFAULT ((0)) NULL,
    [PermisA6]          INT           DEFAULT ((0)) NULL,
    [PermisA7]          INT           DEFAULT ((0)) NULL,
    [PermisA8]          INT           DEFAULT ((0)) NULL,
    [PermisAdm]         INT           DEFAULT ((0)) NULL,
    [PermisMove]        INT           DEFAULT ((0)) NULL,
    [PermisColl]        INT           DEFAULT ((0)) NULL,
    [PermisDrang]       INT           DEFAULT ((0)) NULL,
    [PermisZarp]        INT           DEFAULT ((0)) NULL,
    [PermisFrizer]      INT           DEFAULT ((0)) NULL,
    [Move]              BIT           DEFAULT ((0)) NULL,
    [Chief]             BIT           DEFAULT ((0)) NULL,
    [iGuard_allowedSV]  VARCHAR (256) NULL,
    [PermisTaxi]        INT           NULL,
    [PermisContr]       INT           NULL,
    [PermisP16]         INT           DEFAULT ((0)) NULL,
    [Limit]             INT           DEFAULT ((0)) NULL,
    [PermisFrizRequest] INT           DEFAULT ((0)) NULL,
    [Prikaz]            VARCHAR (50)  NULL,
    [trIDnew]           INT           NULL,
    [spec_id]           INT           NULL,
    [PLID]              INT           DEFAULT ((1)) NOT NULL,
    UNIQUE NONCLUSTERED ([login] ASC),
    CONSTRAINT [usrPwd_uq] UNIQUE NONCLUSTERED ([uin] ASC)
);


GO
CREATE NONCLUSTERED INDEX [usrPwd_idx]
    ON [dbo].[usrPwd]([p_id] ASC);


GO
CREATE TRIGGER [dbo].[usrPwd_UD] ON [dbo].[usrPwd]
WITH EXECUTE AS CALLER
FOR UPDATE, DELETE
AS
BEGIN
  DECLARE @user_id as int;
  DECLARE @user_datetime as datetime;  
  DECLARE @user_type as char(3);
  SET @user_id = 0;
  SET @user_datetime = GETDATE();
  SET @user_type = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                      AND EXISTS(SELECT * FROM DELETED)
                      THEN 'UPD'
                      WHEN EXISTS(SELECT * FROM INSERTED)
                      THEN 'INS'
                      WHEN EXISTS(SELECT * FROM DELETED)
                      THEN 'DEL'
                      ELSE NULL
                  END)
INSERT INTO usrPwdLog(uin, fio, login, trID, p_id, DepID, pwd, Email, Prikaz, user_id, user_datetime, user_type, user_app_name)
SELECT uin, fio, login, trID, p_id, DepID, pwd, Email,  Prikaz, @user_id, @user_datetime, @user_type, app_name() from deleted
END
GO
CREATE TRIGGER [dbo].[usrPwd_I] ON [dbo].[usrPwd]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  DECLARE @user_id as int;
  DECLARE @user_datetime as datetime;  
  DECLARE @user_type as char(3);
  SET @user_id = 0;
  SET @user_datetime = GETDATE();
  SET @user_type = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                      AND EXISTS(SELECT * FROM DELETED)
                      THEN 'UPD'
                      WHEN EXISTS(SELECT * FROM INSERTED)
                      THEN 'INS'
                      WHEN EXISTS(SELECT * FROM DELETED)
                      THEN 'DEL'
                      ELSE NULL
                  END)
  INSERT INTO usrPwdLog(uin, fio, login, trID, p_id, DepID, pwd, Email, Prikaz, user_id, user_datetime, user_type, user_app_name)
  SELECT uin, fio, login, trID, p_id, DepID, pwd, Email, Prikaz, @user_id, @user_datetime, @user_type, app_name() from inserted
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Адрес офис из SkladPlace', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usrPwd', @level2type = N'COLUMN', @level2name = N'PLID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'На основании приказа на подпись документов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usrPwd', @level2type = N'COLUMN', @level2name = N'Prikaz';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Начальник соответсвующего DepID отдела', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usrPwd', @level2type = N'COLUMN', @level2name = N'Chief';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Права исп. Коллекционера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usrPwd', @level2type = N'COLUMN', @level2name = N'PermisColl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Права использ.W_A4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usrPwd', @level2type = N'COLUMN', @level2name = N'PermisA4';

