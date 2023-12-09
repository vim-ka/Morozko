CREATE TABLE [dbo].[AgMon] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [month]           INT            NULL,
    [year]            INT            NULL,
    [p_id]            INT            NULL,
    [depid]           INT            NULL,
    [plan_proc]       NUMERIC (5, 2) NULL,
    [reason_depchief] VARCHAR (255)  NULL,
    [reason_sv]       VARCHAR (255)  NULL,
    [reason_agent]    VARCHAR (255)  NULL,
    [sost]            VARCHAR (5)    NULL,
    [need_action]     VARCHAR (255)  NULL,
    [nd]              DATETIME       CONSTRAINT [DF__AgMon__nd__7BAA2F18] DEFAULT (getdate()) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

