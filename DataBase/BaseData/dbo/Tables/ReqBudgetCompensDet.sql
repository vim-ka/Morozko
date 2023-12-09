CREATE TABLE [dbo].[ReqBudgetCompensDet] (
    [id]     INT             IDENTITY (1, 1) NOT NULL,
    [rbdid]  INT             NULL,
    [ncod]   INT             NULL,
    [summa]  NUMERIC (10, 2) NULL,
    [isget]  BIT             DEFAULT ((0)) NULL,
    [ndget]  DATETIME        NULL,
    [cdetid] INT             NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'cdetid - ссылка на созданную строку бюджета компенсаций', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqBudgetCompensDet';

