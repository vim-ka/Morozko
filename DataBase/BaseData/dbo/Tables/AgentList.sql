CREATE TABLE [dbo].[AgentList] (
    [AG_ID]            SMALLINT       NOT NULL,
    [P_ID]             INT            CONSTRAINT [DF__AgentList__P_ID__65C1E23E] DEFAULT ((0)) NOT NULL,
    [Agent]            VARCHAR (16)   NULL,
    [OrdStick]         BIT            CONSTRAINT [DF__AgentList__OrdSt__249408B6] DEFAULT ((0)) NULL,
    [DepID]            INT            CONSTRAINT [DF__AgentList__DepID__51DBB079] DEFAULT ((0)) NOT NULL,
    [sv_ag_id]         INT            CONSTRAINT [DF__AgentList__sv_ag__52CFD4B2] DEFAULT ((0)) NOT NULL,
    [IsAgent]          BIT            CONSTRAINT [DF__AgentList__IsAge__53C3F8EB] DEFAULT ((0)) NULL,
    [IsSupervis]       BIT            CONSTRAINT [DF__AgentList__IsSup__54B81D24] DEFAULT ((0)) NULL,
    [Remark]           VARCHAR (100)  NULL,
    [SkipSver]         BIT            CONSTRAINT [DF__AgentList__SkipS__5792F321] DEFAULT ((0)) NULL,
    [TmrENAB]          BIT            CONSTRAINT [DF__AgentList__TmrEN__569ECEE8] DEFAULT ((0)) NULL,
    [NomerOP]          AS             ([AG_ID]+(1000)) PERSISTED,
    [AgentPart]        DECIMAL (5, 2) CONSTRAINT [DF__AgentList__Agent__71C95D1E] DEFAULT ((0.7)) NULL,
    [ServerName]       VARCHAR (30)   CONSTRAINT [DF__AgentList__Serve__25882CEF] DEFAULT ('sqlsrv') NOT NULL,
    [FolderName]       VARCHAR (50)   CONSTRAINT [DF__AgentList__Folde__2AECCBE1] DEFAULT ('AgentsWork') NULL,
    [FolderNameBackup] VARCHAR (50)   CONSTRAINT [DF__AgentList__Folde__2A389ECA] DEFAULT ('servertp1') NULL,
    [Merch]            BIT            CONSTRAINT [DF__AgentList__Merch__175B9FD7] DEFAULT ((0)) NULL,
    [WeekPercent]      DECIMAL (5, 1) DEFAULT ((30)) NULL,
    [SkipDover]        BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [AgentList_pk] PRIMARY KEY CLUSTERED ([AG_ID] ASC),
    CONSTRAINT [AgentList_uq2] UNIQUE NONCLUSTERED ([Agent] ASC, [AG_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [AgentList_idx]
    ON [dbo].[AgentList]([P_ID] ASC, [DepID] ASC);


GO
CREATE TRIGGER dbo.AgentList_tri ON dbo.AgentList
WITH EXECUTE AS CALLER
FOR INSERT, UPDATE
AS
BEGIN
   
	update agentlist 
				 set agentlist.FolderNameBackup=d.FolderNameBackup
	from agentlist a
	inner join inserted i on i.ag_id=a.ag_id
	inner join Deps d	on a.DepID=d.DepID
	
END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Можно проводить оплаты без доверенностей', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'SkipDover';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Является мерчендайзером (в КПК передаются виртуальные остатки (999), не включается сверка оборудования)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'Merch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'''Шара'' на сервере с backup', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'FolderNameBackup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'''Шара'' на сервере с рабочим каталогом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'FolderName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Имя сервера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'ServerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Номер оператора', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'NomerOP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Не формировать файл сверки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'SkipSver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Примечание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'Remark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Является супервайзером', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'IsSupervis';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Является агентом', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'IsAgent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код супервайзера', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'sv_ag_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код отдела', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'DepID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Заявка агента "прилипает" к заявке истинного агента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'OrdStick';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оборудование', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'Agent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код из Person', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AgentList', @level2type = N'COLUMN', @level2name = N'P_ID';

