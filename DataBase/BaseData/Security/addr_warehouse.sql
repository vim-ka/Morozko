CREATE SCHEMA [addr_warehouse]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'адресное хранение, структура стеллажей, ячеек', @level0type = N'SCHEMA', @level0name = N'addr_warehouse';

