CREATE TABLE [dbo].[MarshJob] (
    [mjID] INT           IDENTITY (1, 1) NOT NULL,
    [MhID] INT           NOT NULL,
    [Task] VARCHAR (250) NULL,
    [Done] TINYINT       DEFAULT ((0)) NULL,
    [OP]   INT           DEFAULT ((-1)) NOT NULL,
    [nd]   DATETIME      DEFAULT (getdate()) NOT NULL,
    [host] VARCHAR (50)  DEFAULT (host_name()) NOT NULL,
    PRIMARY KEY CLUSTERED ([mjID] ASC),
    CONSTRAINT [MarshJob_fk] FOREIGN KEY ([MhID]) REFERENCES [dbo].[Marsh] ([mhid])
);


GO
ALTER TABLE [dbo].[MarshJob] NOCHECK CONSTRAINT [MarshJob_fk];


GO
CREATE NONCLUSTERED INDEX [MarshJob_idx]
    ON [dbo].[MarshJob]([MhID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0-никак 1-начато 2-наполовину 3-почти готово 4-всё', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshJob', @level2type = N'COLUMN', @level2name = N'Done';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Задание', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshJob', @level2type = N'COLUMN', @level2name = N'Task';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Для связи с Marsh', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarshJob', @level2type = N'COLUMN', @level2name = N'MhID';

