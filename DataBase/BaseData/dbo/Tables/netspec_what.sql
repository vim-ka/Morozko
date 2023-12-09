CREATE TABLE [dbo].[netspec_what] (
    [nmid]          INT             NULL,
    [hitag]         INT             NULL,
    [price]         DECIMAL (15, 5) NULL,
    [isWeightPrice] BIT             DEFAULT ((0)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Если 1, то цена относится к 1 кг веса товара.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'netspec_what', @level2type = N'COLUMN', @level2name = N'isWeightPrice';

