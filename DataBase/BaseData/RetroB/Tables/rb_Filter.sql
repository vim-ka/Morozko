CREATE TABLE [RetroB].[rb_Filter] (
    [RfID] INT     IDENTITY (1, 1) NOT NULL,
    [RbID] INT     NOT NULL,
    [tip]  TINYINT NULL,
    [K]    INT     NULL,
    PRIMARY KEY CLUSTERED ([RfID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 - по всему прайс-листу
1 - за исключением поставщика K
2 - за исключением группы товаров K
3 - за искл. товара с кодом Hitag=K
4 - по поставщику K
5 - по группе товаров K
6 - по товару Hitag=K', @level0type = N'SCHEMA', @level0name = N'RetroB', @level1type = N'TABLE', @level1name = N'rb_Filter', @level2type = N'COLUMN', @level2name = N'tip';

