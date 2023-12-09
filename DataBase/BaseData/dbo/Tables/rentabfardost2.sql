CREATE TABLE [dbo].[rentabfardost2] (
    [date_from]     DATETIME        NULL,
    [date_to]       DATETIME        NULL,
    [fardost_koeff] NUMERIC (18, 3) DEFAULT ((0)) NULL,
    [pin]           INT             NULL,
    [mainparent]    INT             NULL,
    [hitag]         INT             NULL,
    [ncod]          INT             NULL
);


GO
CREATE NONCLUSTERED INDEX [rentabfardost2_idx5]
    ON [dbo].[rentabfardost2]([mainparent] ASC);


GO
CREATE NONCLUSTERED INDEX [rentabfardost2_idx4]
    ON [dbo].[rentabfardost2]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [rentabfardost2_idx2]
    ON [dbo].[rentabfardost2]([date_to] ASC);


GO
CREATE NONCLUSTERED INDEX [rentabfardost2_idx]
    ON [dbo].[rentabfardost2]([date_from] ASC);

