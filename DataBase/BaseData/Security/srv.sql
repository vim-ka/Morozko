CREATE SCHEMA [srv]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'схема для объектов по обслуживанию БД', @level0type = N'SCHEMA', @level0name = N'srv';

