CREATE TABLE [dbo].[NC_ExiteInfo] (
    [datnom]         BIGINT          NOT NULL,
    [OrderDate]      DATETIME        NULL,
    [OrderDocNumber] VARCHAR (35)    NULL,
    [SP_Buyer]       DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [OrderID]        INT             NULL,
    PRIMARY KEY CLUSTERED ([datnom] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NC_ExiteInfo_idx]
    ON [dbo].[NC_ExiteInfo]([OrderDocNumber] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ключ из таблицы exite_orders', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC_ExiteInfo', @level2type = N'COLUMN', @level2name = N'OrderID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Сумма по данным покупателя', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NC_ExiteInfo', @level2type = N'COLUMN', @level2name = N'SP_Buyer';

