CREATE TABLE [dbo].[TSDTasks] (
    [id]    INT           IDENTITY (1, 1) NOT NULL,
    [name]  VARCHAR (60)  NULL,
    [tip]   INT           NULL,
    [code]  INT           NULL,
    [msg]   VARCHAR (255) NULL,
    [dtbeg] DATETIME      NULL,
    [dtend] DATETIME      NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

