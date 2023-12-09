CREATE TABLE [dbo].[ContractNewLog] (
    [id]              INT           NULL,
    [nd]              DATETIME      NULL,
    [ocode]           INT           NULL,
    [icode]           INT           NULL,
    [vid]             INT           NULL,
    [inout]           INT           NULL,
    [otvdep]          INT           NULL,
    [otvlico]         INT           NULL,
    [scannd]          DATETIME      NULL,
    [timetip]         INT           NULL,
    [timebeg]         DATETIME      NULL,
    [timeend]         DATETIME      NULL,
    [timefull]        INT           NULL,
    [urnd]            DATETIME      NULL,
    [ursogl]          DATETIME      NULL,
    [urprim]          VARCHAR (250) NULL,
    [finnd]           DATETIME      NULL,
    [finsogl]         DATETIME      NULL,
    [finprim]         VARCHAR (250) NULL,
    [glbuhnd]         DATETIME      NULL,
    [glbuhsogl]       DATETIME      NULL,
    [glbuhprim]       VARCHAR (250) NULL,
    [glbuhoutd]       DATETIME      NULL,
    [dogtgt]          VARCHAR (512) NULL,
    [dogsogl]         DATETIME      NULL,
    [dogprim]         VARCHAR (512) DEFAULT ('-') NULL,
    [dogstatus]       INT           DEFAULT ((1)) NULL,
    [dogrealnum]      VARCHAR (128) DEFAULT ((-1)) NULL,
    [dogrealdate]     DATETIME      DEFAULT ('01.01.2013') NULL,
    [dogneedsogldate] DATETIME      NULL,
    [dirsogl]         DATETIME      NULL,
    [dirprim]         VARCHAR (250) NULL,
    [arhscan]         DATETIME      NULL,
    [arhprim]         VARCHAR (250) NULL,
    [podtip]          INT           DEFAULT ((0)) NULL,
    [ocodetext]       VARCHAR (250) NULL,
    [groupvid]        INT           NULL,
    [variant]         INT           NULL,
    [resur]           INT           DEFAULT ((-1)) NULL,
    [resfin]          INT           DEFAULT ((-1)) NULL,
    [resglbuh]        INT           DEFAULT ((-1)) NULL,
    [resdir]          INT           DEFAULT ((-1)) NULL,
    [archdocisscan]   INT           DEFAULT ((0)) NULL,
    [initsogl]        DATETIME      NULL,
    [initprim]        VARCHAR (250) NULL,
    [initresume]      INT           DEFAULT ((-1)) NULL,
    [reqinit]         INT           DEFAULT ((-1)) NULL,
    [otvur]           INT           DEFAULT ((-1)) NULL,
    [tovcat]          INT           DEFAULT ((-1)) NULL,
    [srgodn]          INT           NULL,
    [predopl]         BIT           NULL,
    [otsroch]         INT           NULL,
    [compens]         BIT           NULL,
    [samovyvoz]       BIT           NULL,
    [dostaddr]        VARCHAR (512) NULL,
    [opertip]         VARCHAR (3)   NULL,
    [operator]        INT           DEFAULT ((-1)) NULL,
    [operdate]        DATETIME      DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'номер реального договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContractNewLog', @level2type = N'COLUMN', @level2name = N'dogrealnum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'примечание к договору', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContractNewLog', @level2type = N'COLUMN', @level2name = N'dogprim';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата согласования договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContractNewLog', @level2type = N'COLUMN', @level2name = N'dogsogl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'цель заключения договора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContractNewLog', @level2type = N'COLUMN', @level2name = N'dogtgt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'до полного исполнения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContractNewLog', @level2type = N'COLUMN', @level2name = N'timefull';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'дата сканирования из коллекционера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContractNewLog', @level2type = N'COLUMN', @level2name = N'scannd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'вход/исх', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContractNewLog', @level2type = N'COLUMN', @level2name = N'inout';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'контрагент внутренний', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContractNewLog', @level2type = N'COLUMN', @level2name = N'icode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'контрагент внешний', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContractNewLog', @level2type = N'COLUMN', @level2name = N'ocode';

