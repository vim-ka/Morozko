CREATE TABLE [dbo].[MtOrderHro] (
    [id]        INT          IDENTITY (1, 1) NOT NULL,
    [ND]        DATETIME     NULL,
    [Ag_id]     INT          NULL,
    [b_id]      INT          NULL,
    [Hitag]     INT          NULL,
    [qtyInShop] FLOAT (53)   DEFAULT ((0)) NULL,
    [cSKU]      VARCHAR (50) NULL,
    [discAgent] VARCHAR (70) NULL,
    [discSuper] VARCHAR (50) NULL,
    [discChief] VARCHAR (50) NULL,
    CONSTRAINT [MtOrderHro_pk] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [MtOrderHro_uq] UNIQUE NONCLUSTERED ([b_id] ASC, [Hitag] ASC)
);

