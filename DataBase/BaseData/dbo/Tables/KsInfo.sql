CREATE TABLE [dbo].[KsInfo] (
    [kInf]                INT           IDENTITY (1, 1) NOT NULL,
    [ND]                  DATETIME      CONSTRAINT [DF__KsInfo__ND__3C168C8C] DEFAULT (CONVERT([datetime],floor(CONVERT([decimal](38,19),getdate(),(0))),(0))) NULL,
    [DepIDCust]           INT           NULL,
    [DepIDExec]           INT           NULL,
    [Op]                  INT           NULL,
    [Content]             VARCHAR (255) NULL,
    [Remark]              VARCHAR (255) NULL,
    [NeedND]              DATETIME      NULL,
    [Plata]               MONEY         NULL,
    [RemarkExec]          VARCHAR (255) NULL,
    [KsOper]              INT           NULL,
    [RemarkFin]           VARCHAR (255) NULL,
    [PlanND]              DATETIME      NULL,
    [KsIStatusID]         INT           DEFAULT ((0)) NULL,
    [RealND]              DATETIME      NULL,
    [RemarkMain]          VARCHAR (255) NULL,
    [ReqAvail]            BIT           DEFAULT ((0)) NULL,
    [Nal]                 BIT           DEFAULT ((0)) NULL,
    [ReqAv]               SMALLINT      DEFAULT ((0)) NULL,
    [FactND]              DATETIME      NULL,
    [Period]              INT           DEFAULT ((0)) NULL,
    [RemarkMtr]           VARCHAR (255) NULL,
    [Rs]                  INT           DEFAULT ((1)) NULL,
    [Rf]                  SMALLINT      DEFAULT ((0)) NULL,
    [Sent]                BIT           DEFAULT ((0)) NULL,
    [SalaryMonth]         INT           DEFAULT ((0)) NULL,
    [PersonnelDepMessage] VARCHAR (50)  NULL,
    [Type]                INT           DEFAULT ((0)) NULL,
    [tm]                  VARCHAR (8)   DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [rql]                 SMALLINT      NULL,
    [RashFlag]            BIT           NULL,
    [KassID]              INT           NULL,
    CONSTRAINT [KsInfo_pk] PRIMARY KEY CLUSTERED ([kInf] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для связи с Kassa1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KsInfo', @level2type = N'COLUMN', @level2name = N'KassID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Расход', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KsInfo', @level2type = N'COLUMN', @level2name = N'RashFlag';

