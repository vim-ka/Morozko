CREATE TABLE [dbo].[RequestsLog] (
    [Rk]                  INT            NULL,
    [ND]                  DATETIME       NULL,
    [DepIDCust]           INT            DEFAULT ((0)) NULL,
    [DepIDExec]           INT            DEFAULT ((0)) NULL,
    [Op]                  INT            NULL,
    [Content]             VARCHAR (1024) CONSTRAINT [DF__RequestsL__Conte__5D633D15] DEFAULT (' ') NULL,
    [Remark]              VARCHAR (1024) CONSTRAINT [DF__RequestsL__Remar__5E57614E] DEFAULT (' ') NULL,
    [NeedND]              DATETIME       NULL,
    [Plata]               MONEY          NULL,
    [RemarkExec]          VARCHAR (1024) NULL,
    [KsOper]              INT            NULL,
    [RemarkFin]           VARCHAR (1024) NULL,
    [PlanND]              DATETIME       NULL,
    [Status]              INT            NULL,
    [RealND]              DATETIME       NULL,
    [RemarkMain]          VARCHAR (1024) NULL,
    [ReqAvail]            BIT            DEFAULT ((0)) NULL,
    [Nal]                 BIT            DEFAULT ((0)) NULL,
    [ReqAv]               SMALLINT       DEFAULT ((0)) NULL,
    [FactND]              DATETIME       NULL,
    [Period]              INT            DEFAULT ((0)) NULL,
    [RemarkMtr]           VARCHAR (1024) NULL,
    [Rs]                  INT            DEFAULT ((1)) NULL,
    [Rf]                  SMALLINT       DEFAULT ((0)) NULL,
    [Sent]                BIT            DEFAULT ((0)) NULL,
    [SalaryMonth]         INT            DEFAULT ((0)) NULL,
    [PersonnelDepMessage] VARCHAR (50)   NULL,
    [Type]                INT            DEFAULT ((0)) NULL,
    [tm]                  VARCHAR (8)    DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [rql]                 SMALLINT       NULL,
    [Bypass]              INT            NULL,
    [Itsright]            INT            CONSTRAINT [DF__RequestsL__Itsri__68D4EFC1] DEFAULT ((0)) NULL,
    [Data]                VARCHAR (1024) CONSTRAINT [DF__RequestsLo__Data__69C913FA] DEFAULT ('') NULL,
    [PlataOver]           MONEY          NULL,
    [ByCall]              INT            NULL,
    [user_id]             INT            NULL,
    [user_datetime]       DATETIME       NULL,
    [user_type]           VARCHAR (3)    NULL,
    [host_name]           VARCHAR (64)   DEFAULT (host_name()) NULL,
    [user_app_name]       VARCHAR (100)  NULL,
    [otv2]                INT            DEFAULT ((-1)) NULL,
    [tip2]                INT            DEFAULT ((-1)) NULL,
    [data2]               VARCHAR (1024) NULL,
    [resfin2]             INT            DEFAULT ((-1)) NULL,
    [prior2]              INT            DEFAULT ((1)) NULL,
    [ParentRk]            INT            NULL,
    [meta]                INT            NULL,
    [link]                INT            NULL
);


GO
CREATE CLUSTERED INDEX [RequestsLog_idx]
    ON [dbo].[RequestsLog]([Rk] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Превышение бюджета', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'PlataOver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Данные', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'Data';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Это правильно', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'Itsright';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Внешний ключ из ReqQuality', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'rql';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Время создания заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'tm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0-обычная 1-зарплатная', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'Type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сообщение отдела кадров', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'PersonnelDepMessage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Год и месяц зарп., напр. 201112', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'SalaryMonth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Отправлено по почте', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'Sent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Этап исполнения заявки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'Rs';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Период эксплуатации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'Period';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Фактическая дата исполнения ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'FactND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оплата наличными', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'Nal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имеется в наличии', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'ReqAvail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Планируемая дата исполнения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'PlanND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код кассовой операции', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'KsOper';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма закупки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'Plata';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Требуемая дата исполнения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'NeedND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RequestsLog', @level2type = N'COLUMN', @level2name = N'Op';

