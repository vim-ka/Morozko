CREATE TABLE [dbo].[MoveDotsLog] (
    [mdl]      INT      IDENTITY (1, 1) NOT NULL,
    [nd]       DATETIME CONSTRAINT [DF__MoveDotsLog__nd__07DA307C] DEFAULT (dateadd(day,datediff(day,(0),getdate()),(0))) NULL,
    [tm]       CHAR (8) CONSTRAINT [DF__MoveDotsLog__tm__06E60C43] DEFAULT (CONVERT([varchar](8),getdate(),(108))) NULL,
    [dck]      INT      NULL,
    [ag_id]    INT      NULL,
    [sv_ag_id] INT      NULL,
    [takeoff]  BIT      NULL,
    CONSTRAINT [MoveDotsLog_pk] PRIMARY KEY CLUSTERED ([mdl] ASC)
);


GO
CREATE NONCLUSTERED INDEX [MoveDotsLog_idx2]
    ON [dbo].[MoveDotsLog]([dck] ASC);


GO
CREATE NONCLUSTERED INDEX [MoveDotsLog_idx]
    ON [dbo].[MoveDotsLog]([ag_id] ASC);

