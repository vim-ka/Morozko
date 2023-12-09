CREATE TABLE [dbo].[KsOper] (
    [Oper]     INT          NOT NULL,
    [OperName] VARCHAR (70) NULL,
    [RashFlag] BIT          NULL,
    [LostFlag] BIT          NULL,
    CONSTRAINT [KsOper_pk] PRIMARY KEY CLUSTERED ([Oper] ASC)
);

