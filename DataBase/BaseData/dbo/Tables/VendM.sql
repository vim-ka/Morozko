CREATE TABLE [dbo].[VendM] (
    [Ncod]   INT            NOT NULL,
    [Month]  VARCHAR (5)    NULL,
    [hitag]  INT            NULL,
    [Sprice] INT            NULL,
    [Scost]  INT            NULL,
    [Sale]   INT            NULL,
    [SDays]  NUMERIC (7, 4) CONSTRAINT [DF__VendMonth__AgvSa__66B60677_VendM] DEFAULT ((0)) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Продажи за месяц по каждому поставщику', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VendM';

