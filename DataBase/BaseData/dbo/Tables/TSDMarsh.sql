CREATE TABLE [dbo].[TSDMarsh] (
    [id]     INT           IDENTITY (1, 1) NOT NULL,
    [mhid]   INT           NULL,
    [marsh]  INT           NULL,
    [driver] VARCHAR (100) NULL,
    [nd]     DATETIME      NULL,
    [fio]    VARCHAR (100) NULL,
    [regnom] VARCHAR (20)  NULL,
    [mstate] INT           NULL,
    [status] INT           DEFAULT ((0)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

