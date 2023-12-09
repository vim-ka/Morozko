CREATE TABLE [dbo].[Deps] (
    [DepID]            INT          IDENTITY (1, 1) NOT NULL,
    [DName]            VARCHAR (70) NULL,
    [Sale]             BIT          CONSTRAINT [DF__Deps__Sale__42639768] DEFAULT ((0)) NULL,
    [BadBuyersLimit]   SMALLINT     CONSTRAINT [DF__Deps__SkipBuyerL__1B74B2D0] DEFAULT ((5)) NULL,
    [P_ID]             INT          NULL,
    [ParentDep]        INT          NULL,
    [email]            VARCHAR (64) NULL,
    [dep_chief]        INT          NULL,
    [SeqNo]            TINYINT      DEFAULT ((5)) NULL,
    [FolderNameBackup] VARCHAR (50) NULL,
    [Our_ID]           INT          NULL,
    [PLID]             INT          NULL,
    CONSTRAINT [Deps_pk] PRIMARY KEY CLUSTERED ([DepID] ASC),
    CONSTRAINT [UQ__Deps__DB9CAA7EEE509149] UNIQUE NONCLUSTERED ([DepID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Очередь в программе отгрузки с весового склада', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Deps', @level2type = N'COLUMN', @level2name = N'SeqNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'код отдела владельца', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Deps', @level2type = N'COLUMN', @level2name = N'ParentDep';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код накоплений отдела в Person', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Deps', @level2type = N'COLUMN', @level2name = N'P_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Разрешенное число клиентов с просрочкой в отделе', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Deps', @level2type = N'COLUMN', @level2name = N'BadBuyersLimit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Продажи', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Deps', @level2type = N'COLUMN', @level2name = N'Sale';

