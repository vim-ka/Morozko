CREATE TABLE [dbo].[EnabLog] (
    [EID]       INT           IDENTITY (1, 1) NOT NULL,
    [nd]        DATETIME      CONSTRAINT [DF__EnabLog__nd__60757F41] DEFAULT (getdate()) NULL,
    [CompName]  VARCHAR (30)  DEFAULT (host_name()) NULL,
    [B_ID]      INT           NULL,
    [BrFam]     VARCHAR (30)  NULL,
    [ag_id]     INT           NULL,
    [AgFam]     VARCHAR (30)  NULL,
    [sv_id]     INT           NULL,
    [SvFam]     VARCHAR (30)  NULL,
    [Enab]      TINYINT       NULL,
    [CheckDate] DATETIME      NULL,
    [OP]        SMALLINT      NULL,
    [Comment]   VARCHAR (100) NULL,
    [DCK]       INT           NULL,
    CONSTRAINT [PK__EnabLog__C190170B8631368D] PRIMARY KEY CLUSTERED ([EID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [EnabLog_idx4]
    ON [dbo].[EnabLog]([DCK] ASC);


GO
CREATE NONCLUSTERED INDEX [EnabLog_idx3]
    ON [dbo].[EnabLog]([CompName] ASC);


GO
CREATE NONCLUSTERED INDEX [EnabLog_idx2]
    ON [dbo].[EnabLog]([OP] ASC);


GO
CREATE NONCLUSTERED INDEX [EnabLog_idx]
    ON [dbo].[EnabLog]([B_ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Договор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnabLog', @level2type = N'COLUMN', @level2name = N'DCK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Комментарий к блокировке', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnabLog', @level2type = N'COLUMN', @level2name = N'Comment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Оператор', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnabLog', @level2type = N'COLUMN', @level2name = N'OP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Флаг блокировки', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnabLog', @level2type = N'COLUMN', @level2name = N'Enab';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Супервайзер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnabLog', @level2type = N'COLUMN', @level2name = N'sv_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Агент', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnabLog', @level2type = N'COLUMN', @level2name = N'ag_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код клиента', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnabLog', @level2type = N'COLUMN', @level2name = N'B_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Компьютер', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EnabLog', @level2type = N'COLUMN', @level2name = N'CompName';

