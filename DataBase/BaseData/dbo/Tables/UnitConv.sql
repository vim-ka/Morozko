CREATE TABLE [dbo].[UnitConv] (
    [ucID]     INT             IDENTITY (1, 1) NOT NULL,
    [Hitag]    INT             NULL,
    [Unid]     INT             NULL,
    [Unid2]    INT             NULL,
    [K]        DECIMAL (15, 7) NULL,
    [PartEnab] BIT             DEFAULT ((0)) NULL,
    [isdel]    BIT             DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ucID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [uchtg_idx]
    ON [dbo].[UnitConv]([Hitag] ASC);

