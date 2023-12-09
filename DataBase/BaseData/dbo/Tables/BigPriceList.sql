CREATE TABLE [dbo].[BigPriceList] (
    [Hitag]    INT             NULL,
    [B_ID]     INT             NULL,
    [Price]    MONEY           NULL,
    [isWeight] BIT             DEFAULT ((0)) NULL,
    [Comp]     VARCHAR (16)    NULL,
    [OP]       INT             NULL,
    [Saved]    DATETIME        DEFAULT (getdate()) NULL,
    [BakPrice] DECIMAL (15, 5) NULL
);


GO
CREATE NONCLUSTERED INDEX [BigPriceList_idx2]
    ON [dbo].[BigPriceList]([Saved] ASC);


GO
CREATE CLUSTERED INDEX [BigPriceList_idx]
    ON [dbo].[BigPriceList]([Hitag] ASC, [B_ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0:цена 1шт, 1:цена 1кг', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BigPriceList', @level2type = N'COLUMN', @level2name = N'isWeight';

