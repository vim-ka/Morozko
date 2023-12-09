CREATE TABLE [dbo].[FFuelTip] (
    [ftID]   INT          NOT NULL,
    [ftname] VARCHAR (20) NULL,
    [ftCost] MONEY        NULL,
    PRIMARY KEY CLUSTERED ([ftID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Стоимость 1 л', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FFuelTip', @level2type = N'COLUMN', @level2name = N'ftCost';

