CREATE TABLE [dbo].[ReqReturnReason] (
    [id]   INT           IDENTITY (1, 1) NOT NULL,
    [naim] VARCHAR (255) NULL,
    UNIQUE NONCLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'причины возврата товара', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ReqReturnReason';

