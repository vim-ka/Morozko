CREATE TABLE [dbo].[ProcErrors] (
    [id]       INT           IDENTITY (1, 1) NOT NULL,
    [errnum]   INT           NULL,
    [errmess]  VARCHAR (512) NULL,
    [procname] VARCHAR (512) NULL,
    [nd]       DATETIME      DEFAULT (getdate()) NULL,
    [hostname] VARCHAR (64)  DEFAULT (host_name()) NULL,
    [errline]  INT           NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

