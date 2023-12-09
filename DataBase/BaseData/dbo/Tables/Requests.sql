CREATE TABLE [dbo].[Requests] (
    [Rk]                  INT            IDENTITY (1, 1) NOT NULL,
    [ND]                  DATETIME       DEFAULT (getdate()) NULL,
    [DepIDCust]           INT            DEFAULT ((0)) NULL,
    [DepIDExec]           INT            DEFAULT ((0)) NULL,
    [Op]                  INT            DEFAULT ((-1)) NULL,
    [Content]             VARCHAR (1024) CONSTRAINT [DF__Requests__Conten__7BFC0777] DEFAULT (' ') NULL,
    [Remark]              VARCHAR (1024) CONSTRAINT [DF__Requests__Remark__7CF02BB0] DEFAULT (' ') NULL,
    [NeedND]              DATETIME       NULL,
    [Plata]               MONEY          NULL,
    [RemarkExec]          VARCHAR (1024) NULL,
    [KsOper]              INT            NULL,
    [RemarkFin]           VARCHAR (1024) NULL,
    [PlanND]              DATETIME       NULL,
    [Status]              INT            DEFAULT ((1)) NOT NULL,
    [RealND]              DATETIME       NULL,
    [RemarkMain]          VARCHAR (1024) NULL,
    [ReqAvail]            BIT            CONSTRAINT [DF__Requests__ReqAva__0AA94E2A] DEFAULT ((0)) NULL,
    [Nal]                 BIT            CONSTRAINT [DF__Requests__Nal__2CFE662E] DEFAULT ((0)) NULL,
    [ReqAv]               SMALLINT       CONSTRAINT [DF__Requests__ReqAv__2FDAD2D9] DEFAULT ((0)) NULL,
    [FactND]              DATETIME       NULL,
    [Period]              INT            DEFAULT ((0)) NULL,
    [RemarkMtr]           VARCHAR (1024) NULL,
    [Rs]                  INT            CONSTRAINT [DF__Requests__Rs__729CBA6F] DEFAULT ((1)) NULL,
    [Rf]                  SMALLINT       CONSTRAINT [DF__Requests__Rf__121565C8] DEFAULT ((0)) NULL,
    [Sent]                BIT            DEFAULT ((0)) NULL,
    [SalaryMonth]         INT            DEFAULT ((0)) NULL,
    [PersonnelDepMessage] VARCHAR (50)   NULL,
    [Type]                INT            DEFAULT ((0)) NULL,
    [tm]                  VARCHAR (8)    DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [rql]                 SMALLINT       DEFAULT ((0)) NULL,
    [Bypass]              INT            NULL,
    [Itsright]            INT            CONSTRAINT [DF__Requests__Itsrig__13FE7991] DEFAULT ((0)) NULL,
    [Data]                VARCHAR (1024) CONSTRAINT [DF__Requests__Data__14F29DCA] DEFAULT ('') NULL,
    [PlataOver]           MONEY          NULL,
    [ByCall]              INT            NULL,
    [Otv2]                INT            DEFAULT ((-1)) NULL,
    [Tip2]                INT            DEFAULT ((-1)) NULL,
    [Data2]               VARCHAR (1024) NULL,
    [ResFin2]             INT            DEFAULT ((-1)) NULL,
    [Prior2]              INT            DEFAULT ((1)) NULL,
    [ParentRk]            INT            NULL,
    [Locked]              BIT            DEFAULT ((0)) NULL,
    [ResFin2ND]           DATETIME       NULL,
    [compname]            VARCHAR (128)  DEFAULT (host_name()) NULL,
    [ndbuhdoc]            DATETIME       NULL,
    [fp_nd_fix]           DATETIME       NULL,
    [ag_id]               INT            DEFAULT ((-1)) NULL,
    [meta]                INT            DEFAULT ((-1)) NULL,
    [link]                INT            DEFAULT ((-1)) NULL,
    CONSTRAINT [Requests_fk] FOREIGN KEY ([rql]) REFERENCES [dbo].[ReqQuality] ([rql]) ON UPDATE CASCADE,
    CONSTRAINT [Requests_fk2] FOREIGN KEY ([Rs]) REFERENCES [dbo].[ReqStage] ([Rs]) ON UPDATE CASCADE,
    CONSTRAINT [Requests_fk3] FOREIGN KEY ([ReqAv]) REFERENCES [dbo].[ReqAvail] ([reqAv]) ON UPDATE CASCADE,
    CONSTRAINT [Requests_fk4] FOREIGN KEY ([Rf]) REFERENCES [dbo].[ReqFin] ([Rf]) ON UPDATE CASCADE,
    CONSTRAINT [Requests_fk7] FOREIGN KEY ([Op]) REFERENCES [dbo].[usrPwd] ([uin]) ON UPDATE CASCADE,
    CONSTRAINT [Requests_fk8] FOREIGN KEY ([KsOper]) REFERENCES [dbo].[KsOper] ([Oper]) ON UPDATE CASCADE,
    CONSTRAINT [Requests_fk9] FOREIGN KEY ([Status]) REFERENCES [dbo].[ReqStatus] ([Status]) ON UPDATE CASCADE,
    UNIQUE NONCLUSTERED ([Rk] ASC)
);


GO
ALTER TABLE [dbo].[Requests] NOCHECK CONSTRAINT [Requests_fk7];


GO
CREATE NONCLUSTERED INDEX [Requests_idx9]
    ON [dbo].[Requests]([compname] ASC);


GO
CREATE NONCLUSTERED INDEX [Requests_idx8]
    ON [dbo].[Requests]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [Requests_idx7]
    ON [dbo].[Requests]([ND] ASC);


GO
CREATE NONCLUSTERED INDEX [Requests_idx6]
    ON [dbo].[Requests]([Tip2] ASC);


GO
CREATE NONCLUSTERED INDEX [Requests_idx5]
    ON [dbo].[Requests]([Otv2] ASC);


GO
CREATE NONCLUSTERED INDEX [Requests_idx4]
    ON [dbo].[Requests]([rql] ASC);


GO
CREATE NONCLUSTERED INDEX [Requests_idx3]
    ON [dbo].[Requests]([Op] ASC);


GO
CREATE NONCLUSTERED INDEX [Requests_idx2]
    ON [dbo].[Requests]([DepIDExec] ASC);


GO
CREATE NONCLUSTERED INDEX [Requests_idx]
    ON [dbo].[Requests]([DepIDCust] ASC);


GO
CREATE TRIGGER dbo.Requests_UD ON dbo.Requests
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
  INSERT INTO RequestsLog(Rk, ND, DepIDCust, DepIDExec, Op, Content, Remark, NeedND, Plata, RemarkExec, 
KsOper, RemarkFin, PlanND, Status, RealND, RemarkMain, ReqAvail, Nal, ReqAv, FactND, Period, RemarkMtr, 
Rs, Rf, Sent, SalaryMonth, PersonnelDepMessage, Type, tm, rql, Bypass, Itsright, Data, PlataOver, ByCall,
Otv2, Tip2, Data2, ResFin2, Prior2, ParentRk, 
user_id, user_datetime, user_type, user_app_name, meta, link)
SELECT Rk, ND, DepIDCust, DepIDExec, Op, Content, Remark, NeedND, Plata, RemarkExec, 
KsOper, RemarkFin, PlanND, Status, RealND, RemarkMain, ReqAvail, Nal, ReqAv, FactND, Period, RemarkMtr, 
Rs, Rf, Sent, SalaryMonth, PersonnelDepMessage, Type, tm, rql, Bypass, Itsright, Data, PlataOver, ByCall,
Otv2, Tip2, Data2, ResFin2, Prior2, ParentRk, 
@user_id, @user_datetime, @user_type, app_name(), meta, link from deleted
END
GO
CREATE TRIGGER [dbo].[Requests_IParentRk] ON [dbo].[Requests]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  update requests set parentrk = rk where parentrk is null
END
GO
CREATE TRIGGER dbo.Requests_I ON dbo.Requests
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
  INSERT INTO RequestsLog(Rk, ND, DepIDCust, DepIDExec, Op, Content, Remark, NeedND, Plata, RemarkExec, 
KsOper, RemarkFin, PlanND, Status, RealND, RemarkMain, ReqAvail, Nal, ReqAv, FactND, Period, RemarkMtr, 
Rs, Rf, Sent, SalaryMonth, PersonnelDepMessage, Type, tm, rql, Bypass, Itsright, Data, PlataOver, ByCall,
Otv2, Tip2, Data2, ResFin2, Prior2, ParentRk, 
user_id, user_datetime, user_type, user_app_name, meta, link)
SELECT Rk, ND, DepIDCust, DepIDExec, Op, Content, Remark, NeedND, Plata, RemarkExec, 
KsOper, RemarkFin, PlanND, Status, RealND, RemarkMain, ReqAvail, Nal, ReqAv, FactND, Period, RemarkMtr, 
Rs, Rf, Sent, SalaryMonth, PersonnelDepMessage, Type, tm, rql, Bypass, Itsright, Data, PlataOver, ByCall,
Otv2, Tip2, Data2, ResFin2, Prior2, ParentRk,
@user_id, @user_datetime, @user_type, app_name(), meta, link from inserted
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'link ссылка', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'link';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'meta метатип

для заявок на возврат используются значения

4 - брак
5 - просрочка
6 - ликвид', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'meta';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата сдачи док-тов в бухг.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'ndbuhdoc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Резюме фин. службы', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'ResFin2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'содержание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Data2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'тип заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Tip2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ответственный', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Otv2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Превышение бюджета', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'PlataOver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Данные', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Data';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Это правильно', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Itsright';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Внешний ключ из ReqQuality', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'rql';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время создания заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'tm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0-обычная 1-зарплатная', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сообщение отдела кадров', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'PersonnelDepMessage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Год и месяц зарп., напр. 201112', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'SalaryMonth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отправлено по почте', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Sent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Этап исполнения заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Rs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Период эксплуатации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Period';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фактическая дата исполнения ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'FactND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата наличными', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Nal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имеется в наличии', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'ReqAvail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Комментарий директора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'RemarkMain';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата исполнения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'RealND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Планируемая дата исполнения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'PlanND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код кассовой операции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'KsOper';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Комментарий исполнителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'RemarkExec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма закупки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Plata';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Требуемая дата исполнения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'NeedND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Содержание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Content';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'Op';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код отдела исполнителя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'DepIDExec';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код отдела заказчика ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'DepIDCust';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата создания заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Requests', @level2type = N'COLUMN', @level2name = N'ND';

