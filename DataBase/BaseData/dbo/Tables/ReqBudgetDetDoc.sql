CREATE TABLE [dbo].[ReqBudgetDetDoc] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [rbd_id]      INT           NULL,
    [docext]      VARCHAR (5)   NULL,
    [docimage]    IMAGE         NULL,
    [docprim]     VARCHAR (255) NULL,
    [doctemppath] VARCHAR (255) NULL,
    [docsize]     INT           NULL,
    CONSTRAINT [ReqBudgetDetDoc_uq] UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'документы к пунктам заявки на бюджет', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqBudgetDetDoc';

