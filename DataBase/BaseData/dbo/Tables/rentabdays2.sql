CREATE TABLE [dbo].[rentabdays2] (
    [date_from]  DATETIME NULL,
    [date_to]    DATETIME NULL,
    [days]       INT      NULL,
    [pin]        INT      NULL,
    [mainparent] INT      NULL,
    [hitag]      INT      NULL,
    [ncod]       INT      NULL
);


GO
CREATE NONCLUSTERED INDEX [rentabdays2_idx5]
    ON [dbo].[rentabdays2]([mainparent] ASC);


GO
CREATE NONCLUSTERED INDEX [rentabdays2_idx4]
    ON [dbo].[rentabdays2]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [rentabdays2_idx2]
    ON [dbo].[rentabdays2]([date_to] ASC);


GO
CREATE NONCLUSTERED INDEX [rentabdays2_idx]
    ON [dbo].[rentabdays2]([date_from] ASC);

