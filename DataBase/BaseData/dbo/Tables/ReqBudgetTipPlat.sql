CREATE TABLE [dbo].[ReqBudgetTipPlat] (
    [id]   INT          IDENTITY (1, 1) NOT NULL,
    [name] VARCHAR (16) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

