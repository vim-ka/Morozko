CREATE TABLE [dbo].[VendBaseCosts] (
    [vbsID]    INT             IDENTITY (1, 1) NOT NULL,
    [Pin]      INT             NULL,
    [Dck]      INT             NULL,
    [Hitag]    INT             NULL,
    [Basecost] DECIMAL (15, 5) NULL,
    PRIMARY KEY CLUSTERED ([vbsID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [vbs_idx]
    ON [dbo].[VendBaseCosts]([Pin] ASC, [Dck] ASC);

