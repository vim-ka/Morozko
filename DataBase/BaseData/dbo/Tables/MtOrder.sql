CREATE TABLE [dbo].[MtOrder] (
    [id]          INT        IDENTITY (1, 1) NOT NULL,
    [dtOrder]     DATETIME   NULL,
    [b_id]        INT        NULL,
    [Hitag]       INT        NULL,
    [qtyInShop]   FLOAT (53) CONSTRAINT [DF__MtOrder__qtyInSh__68BD7F23] DEFAULT ((0)) NULL,
    [qtyOrder]    INT        NULL,
    [minQty]      FLOAT (53) CONSTRAINT [DF__MtOrder__minQty__0169315C] DEFAULT ((0)) NULL,
    [dtBeg]       DATETIME   CONSTRAINT [DF__MtOrder__dtBeg__08E035F2] DEFAULT (getdate()) NULL,
    [dtEnd]       DATETIME   CONSTRAINT [DF__MtOrder__dtEnd__07EC11B9] DEFAULT (getdate()+(3950)) NULL,
    [ffid]        TINYINT    DEFAULT ((0)) NULL,
    [LastSellDay] DATETIME   NULL,
    CONSTRAINT [MtOrder_pk] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [MtOrder_uq] UNIQUE NONCLUSTERED ([b_id] ASC, [Hitag] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Дата последней продажи. Заполняется в полночь.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MtOrder', @level2type = N'COLUMN', @level2name = N'LastSellDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Тип ларя, см. FrizerFunc.ffid', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MtOrder', @level2type = N'COLUMN', @level2name = N'ffid';

