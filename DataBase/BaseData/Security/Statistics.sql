CREATE SCHEMA [Statistics]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'для сбора статистик', @level0type = N'SCHEMA', @level0name = N'Statistics';

