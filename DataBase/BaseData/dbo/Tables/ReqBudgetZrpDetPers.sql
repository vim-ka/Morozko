CREATE TABLE [dbo].[ReqBudgetZrpDetPers] (
    [id]               INT             IDENTITY (1, 1) NOT NULL,
    [mn]               SMALLINT        NULL,
    [yr]               SMALLINT        NULL,
    [additionaltypeid] INT             NULL,
    [depid]            INT             NULL,
    [p_id]             INT             NULL,
    [isum]             NUMERIC (12, 2) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);

