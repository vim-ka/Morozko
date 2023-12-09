CREATE TABLE [dbo].[AdvOrder] (
    [pin]      NUMERIC (5)    NULL,
    [date]     DATETIME       NULL,
    [hitag]    NUMERIC (6)    NULL,
    [qty]      NUMERIC (4, 1) NULL,
    [complete] BIT            NULL,
    [name]     VARCHAR (30)   NULL,
    [Remark]   VARCHAR (50)   NULL,
    [ag_id]    TINYINT        NULL,
    [nd]       DATETIME       NULL,
    [dck]      INT            NULL
);


GO
CREATE NONCLUSTERED INDEX [AdvOrder_idx5]
    ON [dbo].[AdvOrder]([dck] ASC);


GO
CREATE NONCLUSTERED INDEX [AdvOrder_idx4]
    ON [dbo].[AdvOrder]([nd] ASC);


GO
CREATE NONCLUSTERED INDEX [AdvOrder_idx3]
    ON [dbo].[AdvOrder]([ag_id] ASC);


GO
CREATE NONCLUSTERED INDEX [AdvOrder_idx2]
    ON [dbo].[AdvOrder]([hitag] ASC);


GO
CREATE NONCLUSTERED INDEX [AdvOrder_idx]
    ON [dbo].[AdvOrder]([pin] ASC);

