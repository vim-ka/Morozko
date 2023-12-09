CREATE TABLE [dbo].[Obl] (
    [Obl_ID]  NUMERIC (2)  IDENTITY (1, 1) NOT NULL,
    [OblName] VARCHAR (50) NULL,
    [RegCode] VARCHAR (3)  DEFAULT ('') NULL,
    PRIMARY KEY CLUSTERED ([Obl_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Obl_idx]
    ON [dbo].[Obl]([Obl_ID] ASC);


GO
ALTER INDEX [Obl_idx]
    ON [dbo].[Obl] DISABLE;


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Код региона', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Obl', @level2type = N'COLUMN', @level2name = N'RegCode';

