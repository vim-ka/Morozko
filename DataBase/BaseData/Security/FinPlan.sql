CREATE SCHEMA [FinPlan]
    AUTHORIZATION [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Финансовое планирование', @level0type = N'SCHEMA', @level0name = N'FinPlan';

