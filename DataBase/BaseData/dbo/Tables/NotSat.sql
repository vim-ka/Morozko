CREATE TABLE [dbo].[NotSat] (
    [ND]            DATETIME        DEFAULT (dateadd(day,datediff(day,(0),getdate()),(0))) NULL,
    [TM]            CHAR (8)        DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [OP]            INT             NULL,
    [B_ID]          INT             NULL,
    [Ag_ID]         INT             NULL,
    [Ncod]          INT             NULL,
    [Hitag]         INT             NULL,
    [Sklad]         INT             NULL,
    [Qty]           DECIMAL (10, 3) NULL,
    [Price]         MONEY           NULL,
    [Cost]          MONEY           NULL,
    [tekid]         INT             DEFAULT (0) NULL,
    [ves]           DECIMAL (10, 3) DEFAULT (0) NULL,
    [Remark]        VARCHAR (50)    NULL,
    [SkladOpt]      INT             NULL,
    [SkladRozn]     INT             NULL,
    [SkladAccum]    INT             NULL,
    [SkladLock]     INT             NULL,
    [DCK]           INT             NULL,
    [NSID]          INT             IDENTITY (1, 1) NOT NULL,
    [SkladSafeCust] INT             NULL,
    CONSTRAINT [NotSat_pk] PRIMARY KEY CLUSTERED ([NSID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NotSat_idx3]
    ON [dbo].[NotSat]([B_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [NotSat_idx2]
    ON [dbo].[NotSat]([Ag_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [NotSat_idx]
    ON [dbo].[NotSat]([ND] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во на складе ответ. хранения', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotSat', @level2type = N'COLUMN', @level2name = N'SkladSafeCust';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во заблокированного на складе', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotSat', @level2type = N'COLUMN', @level2name = N'SkladLock';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во на складах накопителях', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotSat', @level2type = N'COLUMN', @level2name = N'SkladAccum';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во на розничных складах', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotSat', @level2type = N'COLUMN', @level2name = N'SkladRozn';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Кол-во на оптовых складах', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotSat', @level2type = N'COLUMN', @level2name = N'SkladOpt';

