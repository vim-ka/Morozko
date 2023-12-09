CREATE TABLE [VanSell].[spec] (
    [sid]    INT             IDENTITY (1, 1) NOT NULL,
    [pin]    INT             NULL,
    [hitag]  INT             NULL,
    [price]  NUMERIC (10, 2) NULL,
    [taskid] INT             NULL,
    UNIQUE NONCLUSTERED ([sid] ASC)
);

