CREATE TABLE [dbo].[AgentListHistory] (
    [Hist]             INT            IDENTITY (1, 1) NOT NULL,
    [NDClose]          DATETIME       NULL,
    [AG_ID]            SMALLINT       NOT NULL,
    [P_ID]             INT            CONSTRAINT [DF__AgentListHistory__P_ID__65C1E23E] DEFAULT ((0)) NOT NULL,
    [Agent]            VARCHAR (16)   NULL,
    [OrdStick]         BIT            CONSTRAINT [DF__AgentListHistory__OrdSt__249408B6] DEFAULT ((0)) NULL,
    [DepID]            INT            CONSTRAINT [DF__AgentListHistory__DepID__51DBB079] DEFAULT ((0)) NOT NULL,
    [sv_ag_id]         INT            CONSTRAINT [DF__AgentListHistory__sv_ag__52CFD4B2] DEFAULT ((0)) NOT NULL,
    [IsAgent]          BIT            CONSTRAINT [DF__AgentListHistory__IsAge__53C3F8EB] DEFAULT ((0)) NULL,
    [IsSupervis]       BIT            CONSTRAINT [DF__AgentListHistory__IsSup__54B81D24] DEFAULT ((0)) NULL,
    [Remark]           VARCHAR (100)  NULL,
    [SkipSver]         BIT            CONSTRAINT [DF__AgentListHistory__SkipS__5792F321] DEFAULT ((0)) NULL,
    [ADD_AG_ID]        VARCHAR (254)  NULL,
    [TmrENAB]          BIT            CONSTRAINT [DF__AgentListHistory__TmrEN__569ECEE8] DEFAULT ((0)) NULL,
    [AgentPart]        DECIMAL (5, 2) CONSTRAINT [DF__AgentListHistory__Agent__71C95D1E] DEFAULT ((0.7)) NULL,
    [ServerName]       VARCHAR (30)   CONSTRAINT [DF__AgentListHistory__Serve__25882CEF] DEFAULT ('sqlsrv') NOT NULL,
    [FolderName]       VARCHAR (50)   CONSTRAINT [DF__AgentListHistory__Folde__2AECCBE1] DEFAULT ('AgentsW') NULL,
    [FolderNameBackup] VARCHAR (50)   CONSTRAINT [DF__AgentListHistory__Folde__2A389ECA] DEFAULT ('Tpsrv_gorod') NULL,
    [Merch]            BIT            CONSTRAINT [DF__AgentListHistory__Merch__175B9FD7] DEFAULT ((0)) NULL,
    [NomerOP]          INT            NULL,
    CONSTRAINT [AgentListHistory_pk] PRIMARY KEY CLUSTERED ([Hist] ASC),
    CONSTRAINT [AgentListHistory_uq2] UNIQUE NONCLUSTERED ([Agent] ASC, [AG_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [AgentListHistory_idx]
    ON [dbo].[AgentListHistory]([P_ID] ASC, [DepID] ASC);


GO


CREATE TRIGGER [dbo].[AgentListHistory_tri] ON [dbo].[AgentListHistory]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN
  
	update agentlist 
				 set agentlist.FolderNameBackup=d.FolderNameBackup
	from agentlist a
	inner join inserted i on i.ag_id=a.ag_id
	inner join Deps d	on a.DepID=d.DepID
	
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Является мерчендайзером (в КПК передаются виртуальные остатки (999), не включается сверка оборудования)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'Merch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'''Шара'' на сервере с backup', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'FolderNameBackup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'''Шара'' на сервере с рабочим каталогом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'FolderName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имя сервера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'ServerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'к удалению', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'ADD_AG_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Не формировать файл сверки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'SkipSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Является супервайзером', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'IsSupervis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Является агентом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'IsAgent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код супервайзера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'sv_ag_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код отдела', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Заявка агента "прилипает" к заявке истинного агента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'OrdStick';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оборудование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'Agent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код из Person', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentListHistory', @level2type = N'COLUMN', @level2name = N'P_ID';

