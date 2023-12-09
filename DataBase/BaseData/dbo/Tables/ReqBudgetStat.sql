CREATE TABLE [dbo].[ReqBudgetStat] (
    [id]    INT          IDENTITY (1, 1) NOT NULL,
    [sname] VARCHAR (64) NULL,
    [ord]   INT          DEFAULT ((1)) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

