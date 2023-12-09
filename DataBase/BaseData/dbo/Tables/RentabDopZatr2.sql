CREATE TABLE [dbo].[RentabDopZatr2] (
    [date_from] DATETIME        NULL,
    [date_to]   DATETIME        NULL,
    [pin]       INT             NULL,
    [calctip]   INT             NULL,
    [sumz]      NUMERIC (12, 2) DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [RentabDopZatr2_idx4]
    ON [dbo].[RentabDopZatr2]([pin] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabDopZatr2_idx2]
    ON [dbo].[RentabDopZatr2]([date_to] ASC);


GO
CREATE NONCLUSTERED INDEX [RentabDopZatr2_idx]
    ON [dbo].[RentabDopZatr2]([date_from] ASC);

