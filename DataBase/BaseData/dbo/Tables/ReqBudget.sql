CREATE TABLE [dbo].[ReqBudget] (
    [id]         INT             IDENTITY (1, 1) NOT NULL,
    [nd]         DATETIME        NULL,
    [p_id]       INT             NULL,
    [depid]      INT             NULL,
    [month]      INT             NULL,
    [year]       INT             NULL,
    [dep_dir]    INT             NULL,
    [comm]       VARCHAR (1024)  NULL,
    [stat]       INT             DEFAULT ((1)) NULL,
    [locked]     BIT             DEFAULT ((0)) NULL,
    [bsum]       NUMERIC (16, 2) DEFAULT ((0)) NULL,
    [finaccnd]   DATETIME        NULL,
    [diraccnd]   DATETIME        NULL,
    [sendfinnd]  DATETIME        NULL,
    [dirreqstat] INT             NULL,
    [dircomm]    VARCHAR (512)   NULL,
    [fincomm]    VARCHAR (512)   NULL,
    [tip]        TINYINT         CONSTRAINT [DF__ReqBudget__tip__7684BBF1] DEFAULT ((0)) NULL,
    [razvnd]     DATETIME        NULL,
    [razvcomm]   VARCHAR (512)   NULL,
    [parent_id]  INT             DEFAULT ((-1)) NULL,
    CONSTRAINT [ReqBudget_fk] FOREIGN KEY ([stat]) REFERENCES [dbo].[ReqBudgetStat] ([id]),
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tip 0 - обычный бюджет
tip 1 - бюджет по превышениям
tip 2 - бюджет компенсации', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqBudget';

