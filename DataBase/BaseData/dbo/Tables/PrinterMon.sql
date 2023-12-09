CREATE TABLE [dbo].[PrinterMon] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [job_id]       INT           NULL,
    [printer_name] VARCHAR (255) NULL,
    [user_name]    VARCHAR (255) NULL,
    [machine_name] VARCHAR (255) NULL,
    [doc_name]     VARCHAR (255) NULL,
    [total_pages]  INT           NULL,
    [nd]           DATETIME      NULL,
    [status]       VARCHAR (255) NULL,
    [opdate]       DATETIME      DEFAULT (getdate()) NOT NULL,
    [doc_size]     INT           NULL,
    [duplex]       INT           NULL,
    [copies]       INT           DEFAULT ((1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

