CREATE TABLE [dbo].[ReqHitag] (
    [Comp]  VARCHAR (16) NULL,
    [Hitag] INT          NULL
);


GO
CREATE CLUSTERED INDEX [ReqHitag_idx]
    ON [dbo].[ReqHitag]([Comp] ASC, [Hitag] ASC);

