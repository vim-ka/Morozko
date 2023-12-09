CREATE TABLE [dbo].[rentabneardost2] (
    [date_from]      DATETIME        NULL,
    [date_to]        DATETIME        NULL,
    [neardost_koeff] NUMERIC (18, 3) DEFAULT ((0)) NULL,
    [pin]            INT             NULL,
    [mainparent]     INT             NULL,
    [hitag]          INT             NULL,
    [ncod]           INT             NULL
);


GO
CREATE NONCLUSTERED INDEX [rentabneardost2_idx5]
    ON [dbo].[rentabneardost2]([mainparent] ASC);


GO
CREATE NONCLUSTERED INDEX [rentabneardost2_idx4]
    ON [dbo].[rentabneardost2]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [rentabneardost2_idx2]
    ON [dbo].[rentabneardost2]([date_to] ASC);


GO
CREATE NONCLUSTERED INDEX [rentabneardost2_idx]
    ON [dbo].[rentabneardost2]([date_from] ASC);

