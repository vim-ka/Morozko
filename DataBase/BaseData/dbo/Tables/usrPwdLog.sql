CREATE TABLE [dbo].[usrPwdLog] (
    [uin]               INT           NULL,
    [fio]               VARCHAR (70)  NULL,
    [login]             VARCHAR (20)  NULL,
    [trID]              INT           NULL,
    [p_id]              INT           NULL,
    [DepID]             SMALLINT      NULL,
    [pwd]               VARCHAR (32)  CONSTRAINT [DF__usrPwdLog__pwd__6A85CC04] DEFAULT ('202CB962AC59075B964B07152D234B70') NULL,
    [Email]             VARCHAR (50)  NULL,
    [NumScore]          VARCHAR (20)  NULL,
    [rights]            INT           CONSTRAINT [DF__usrPwdLog__rights__5887175A] DEFAULT ((0)) NULL,
    [Price3]            BIT           CONSTRAINT [DF__usrPwdLog__Price3__48EFCE0F] DEFAULT ((0)) NULL,
    [Rtr]               BIT           CONSTRAINT [DF__usrPwdLog__Rtr__422DC1E7] DEFAULT ((0)) NULL,
    [Extra]             BIT           CONSTRAINT [DF__usrPwdLog__Extra__17CD73C7] DEFAULT ((0)) NULL,
    [Price]             BIT           CONSTRAINT [DF__usrPwdLog__Price__6F556E19] DEFAULT ((0)) NULL,
    [PermisA2]          INT           CONSTRAINT [DF__usrPwdLog__PermisA2__6CD8F421] DEFAULT ((0)) NULL,
    [PermisA4]          INT           CONSTRAINT [DF__usrPwdLog__PermisA4__276FAA0A] DEFAULT ((0)) NULL,
    [PermisA5]          INT           CONSTRAINT [DF__usrPwdLog__PermisA5__4ED38FEE] DEFAULT ((0)) NULL,
    [PermisA6]          INT           CONSTRAINT [DF__usrPwdLog__PermisA6__7AF2094E] DEFAULT ((0)) NULL,
    [PermisA7]          INT           CONSTRAINT [DF__usrPwdLog__PermisA7__0619A337] DEFAULT ((0)) NULL,
    [PermisA8]          INT           CONSTRAINT [DF__usrPwdLog__PermisA8__73DAF76B] DEFAULT ((0)) NULL,
    [PermisAdm]         INT           CONSTRAINT [DF__usrPwdLog__PermisAd__458A1CD6] DEFAULT ((0)) NULL,
    [PermisMove]        INT           CONSTRAINT [DF__usrPwdLog__PermisMo__5E8AD4CA] DEFAULT ((0)) NULL,
    [PermisColl]        INT           CONSTRAINT [DF__usrPwdLog__PermisCo__14B1DB51] DEFAULT ((0)) NULL,
    [PermisDrang]       INT           CONSTRAINT [DF__usrPwdLog__PermisDr__1CDD0CFE] DEFAULT ((0)) NULL,
    [PermisZarp]        INT           CONSTRAINT [DF__usrPwdLog__PermisZa__070DC770] DEFAULT ((0)) NULL,
    [PermisFrizer]      INT           CONSTRAINT [DF__usrPwdLog__PermisFr__774C60F3] DEFAULT ((0)) NULL,
    [A2]                BIT           CONSTRAINT [DF__usrPwdLog__A2__4242D080] DEFAULT ((0)) NULL,
    [A3]                BIT           CONSTRAINT [DF__usrPwdLog__A3__4336F4B9] DEFAULT ((0)) NULL,
    [A4]                BIT           CONSTRAINT [DF__usrPwdLog__A4__442B18F2] DEFAULT ((0)) NULL,
    [A5]                BIT           CONSTRAINT [DF__usrPwdLog__A5__451F3D2B] DEFAULT ((0)) NULL,
    [A6]                BIT           CONSTRAINT [DF__usrPwdLog__A6__4C771187] DEFAULT ((0)) NULL,
    [A7]                BIT           CONSTRAINT [DF__usrPwdLog__A7__4707859D] DEFAULT ((0)) NULL,
    [A8]                BIT           CONSTRAINT [DF__usrPwdLog__A8__47FBA9D6] DEFAULT ((0)) NULL,
    [Adm]               BIT           CONSTRAINT [DF__usrPwdLog__Adm__381A47C8] DEFAULT ((0)) NULL,
    [Move]              BIT           CONSTRAINT [DF__usrPwdLog__Move__5F7EF903] DEFAULT ((0)) NULL,
    [Guard]             BIT           CONSTRAINT [DF__usrPwdLog__Guard__7F16D496] DEFAULT ((0)) NULL,
    [Chief]             BIT           CONSTRAINT [DF__usrPwdLog__Chief__53CE1A8C] DEFAULT ((0)) NULL,
    [iGuard_allowedSV]  VARCHAR (256) NULL,
    [PermisTaxi]        INT           NULL,
    [PermisContr]       INT           NULL,
    [PermisP16]         INT           CONSTRAINT [DF__usrPwdLog__PermisP1__519BB957] DEFAULT ((0)) NULL,
    [Limit]             INT           CONSTRAINT [DF__usrPwdLog__Limit__54782602] DEFAULT ((0)) NULL,
    [PermisFrizRequest] INT           CONSTRAINT [DF__usrPwdLog__PermisFr__1DE70B27] DEFAULT ((0)) NULL,
    [Prikaz]            VARCHAR (50)  NULL,
    [trIDnew]           INT           NULL,
    [spec_id]           INT           NULL,
    [user_id]           INT           NULL,
    [user_datetime]     DATETIME      NULL,
    [user_type]         VARCHAR (3)   NULL,
    [user_app_name]     VARCHAR (100) NULL,
    [host_name]         VARCHAR (64)  DEFAULT (host_name()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'приказ на подпись документов', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usrPwdLog', @level2type = N'COLUMN', @level2name = N'Prikaz';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Начальник соответсвующего DepID отдела', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usrPwdLog', @level2type = N'COLUMN', @level2name = N'Chief';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Права исп. Коллекционера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usrPwdLog', @level2type = N'COLUMN', @level2name = N'PermisColl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Права использ.W_A4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usrPwdLog', @level2type = N'COLUMN', @level2name = N'PermisA4';

