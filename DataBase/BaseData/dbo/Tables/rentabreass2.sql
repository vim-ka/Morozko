CREATE TABLE [dbo].[rentabreass2] (
    [date_from] DATETIME        NULL,
    [date_to]   DATETIME        NULL,
    [ncod]      INT             NULL,
    [plata]     NUMERIC (18, 2) DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [rentabreass2_idx2]
    ON [dbo].[rentabreass2]([date_to] ASC);


GO
CREATE NONCLUSTERED INDEX [rentabreass2_idx]
    ON [dbo].[rentabreass2]([date_from] ASC);

